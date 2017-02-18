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

          loader = GraphQL::ActiveRecordBatcher::AssociationLoader.new(
            model,
            associations
          )

          # "Wrap" the resolve proc with our own, which returns a promise
          old_resolve_proc = field.resolve_proc
          new_resolve_proc = ->(obj, args, ctx) do
            loader.load(obj).then { old_resolve_proc.call(obj, args, ctx) }
          end

          field.redefine do
            resolve(new_resolve_proc)
          end
        else
          field
        end
      end

      private

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
