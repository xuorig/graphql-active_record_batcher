require 'graphql/active_record_preload/version'
require 'graphql/active_record_preload/field_instrumenter'
require 'graphql/active_record_preload/find_by_id_loader'
require 'graphql/active_record_preload/find_field'
require 'graphql/active_record_preload/association_loader'

module GraphQL
  module ActiveRecordBatcher
    def self.setup(schema)
      schema.instrumenters[:field] << GraphQL::ActiveRecordBatcher::FieldInstrumenter
      GraphQL::Field.accepts_definitions(preloads: GraphQL::Define.assign_metadata_key(:preloads))
      GraphQL::ObjectType.accepts_definitions(model: GraphQL::Define.assign_metadata_key(:model))
    end
  end
end
