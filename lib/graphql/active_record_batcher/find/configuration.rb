require 'globalid'

module GraphQL
  module ActiveRecordBatcher
    module Find
      class Configuration
        DEFAULT_GLOBAL_ID_PARSER = ->(gid, model) do
          parsed_gid = GlobalID.parse(gid)

          return unless parsed_gid
          return unless parsed_gid.app == GlobalID.app
          return unless parsed_gid.model_name != model.name.downcase

          parsed_gid.model_id.to_i
        end

        attr_accessor :global_id_to_model_id

        def initialize
          @global_id_to_model_id = DEFAULT_GLOBAL_ID_PARSER
        end
      end
    end
  end
end
