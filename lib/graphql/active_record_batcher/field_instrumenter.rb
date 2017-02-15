module GraphQL
  module ActiveRecordBatcher
    class FieldInstrumenter
      def instrument(type, field)
        association_to_preload = field.metadata[:preloads]

        if association_to_preload
          # Model is needed to preload an association
          unless model = type.metadata[:model]
            message = "No ActiveRecord Model set on type #{type.name}'s metadata."\
              " Use `model(YourActiveRecordModel)` inside the type's definition"
            raise StandardError, message
          end

          # Make sure the association exists on the model
          validate_preload(model, association_to_preload)

          loader = GraphQL::ActiveRecordBatcher::AssociationLoader.new(
            model,
            association_to_preload
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

      def validate_preload(model, association_to_preload)
        unless model.reflect_on_association(association_to_preload)
          raise ArgumentError, "No association `#{association_to_preload}` on model `#{model}`"
        end
      end
    end
  end
end
