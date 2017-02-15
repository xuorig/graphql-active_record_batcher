module GraphQL
  module ActiveRecordBatcher
    module FindField
      def self.for(type:, model:)
        GraphQL::Field.define do
          type type
          argument :id, !types.ID
          resolve ->(_, args, _) do
            parse_id_proc = ActiveRecordBatcher.model_id_from_global_id
            model_id = parse_id_proc.call(args[:id], model)
            GraphQL::ActiveRecordBatcher::FindByIdLoader.for(model).load(model_id)
          end
        end
      end
    end
  end
end
