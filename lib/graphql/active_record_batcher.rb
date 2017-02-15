require 'graphql/active_record_batcher/version'
require 'graphql/active_record_batcher/field_instrumenter'
require 'graphql/active_record_batcher/association_loader'

module GraphQL
  module ActiveRecordBatcher
  end
end

GraphQL::Field.accepts_definitions(preloads: GraphQL::Define.assign_metadata_key(:preloads))
GraphQL::ObjectType.accepts_definitions(model: GraphQL::Define.assign_metadata_key(:model))
