module GraphQL
  module ActiveRecordBatcher
    class FieldInstrumenter
      def instrument(type, field)
        associations = field.metadata[:preloads]

        if associations
          # Model is needed to preload an association
          unless model = type.metadata[:model]
            message = "No ActiveRecord Model set on type #{type.name}'s metadata."\
              " Use `model(YourActiveRecordModel)` inside the type's definition"
            raise StandardError, message
          end

          # Make sure the association exists on the model
          validate(model, associations)

          # "Wrap" the resolve proc with our own, which returns a promise
          old_resolve_proc = field.resolve_proc
          new_resolve_proc = ->(obj, args, ctx) do
            build_preload_promise(obj, model, associations).then do
              old_resolve_proc.call(obj, args, ctx)
            end
          end

          field.redefine do
            resolve(new_resolve_proc)
          end
        else
          field
        end
      end

      private

      def build_preload_promise(object, model, associations)
        if associations.is_a?(Array)
          Promise.all(associations.map do |association|
            loader_for(model, association).load(object)
          end)
        else
          loader_for(model, associations).load(object)
        end
      end

      def loader_for(model, association)
        GraphQL::ActiveRecordBatcher::AssociationLoader.for(
          model,
          association
        )
      end

      def validate(model, associations)
        case associations
        when Symbol
          validate_association(model, associations)
        when Array
          associations.each { |association| validate_association(model, association) }
        else
          raise ArgumentError, "Cannot preload associations #{associations}."\
            "Use a Symbol to preload one association or an Array of Symbols to load many."
        end
      end

      def validate_association(model, association_to_preload)
        unless model.reflect_on_association(association_to_preload)
          raise ArgumentError, "No association `#{association_to_preload}` on model `#{model}`"
        end
      end
    end
  end
end
