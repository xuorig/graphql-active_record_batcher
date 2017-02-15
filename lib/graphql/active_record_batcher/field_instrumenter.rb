module GraphQL
  module ActiveRecordBatcher
    class FieldInstrumenter
      def instrument(type, field)
        model = type.metadata[:model]
        association_to_preload = field.metadata[:preload]

        if association_to_preload
          # Make sure the association exists on the model
          validate_preload(model, association_to_preload)

          loader = GraphQL::ActiveRecord::Preload::AssociationLoader.new(
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

      def validate_preload(type, association_to_preload)
        model = type.metadata[:model]

        unless model.reflect_on_association(association_to_preload)
          raise ArgumentError, "No association #{@association_name} on #{@model}"
        end
      end
    end
  end
end
