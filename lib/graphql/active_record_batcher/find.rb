require 'graphql/active_record_batcher/find/configuration'
require 'graphql/active_record_batcher/find/loader'

module GraphQL
  module ActiveRecordBatcher
    module Find
      def self.field(type:, model:)
        GraphQL::Field.define do
          type(type)
          argument(:id, !types.ID)
          resolve ->(_, args, _) do
            gid = args[:id]
            model_id = Find.config.global_id_to_model_id.(gid, model)
            Loader.for(model).load(model_id)
          end
        end
      end

      def self.configure
        @config ||= Configuration.new
        yield(@config) if block_given?
        @config
      end

      def self.config
        @config || configure
      end
    end
  end
end
