require 'graphql/active_record_batcher/version'
require 'graphql/active_record_batcher/field_instrumenter'
require 'graphql/active_record_batcher/association_loader'
require 'graphql/active_record_batcher/find'

module GraphQL
  module ActiveRecordBatcher
  end
end

# Accept a preloads attribute on fields
GraphQL::Field.accepts_definitions(preloads: GraphQL::Define.assign_metadata_key(:preloads))

# For association preloading we need to know which Mode we are dealing with
GraphQL::ObjectType.accepts_definitions(model: GraphQL::Define.assign_metadata_key(:model))

# A definition on schema lets us avoid documenting how to setup instrumenters
GraphQL::Schema.accepts_definitions(enable_active_record_batching: ->(schema) {
  schema.lazy_methods.set(Promise, :sync)
  schema.instrument(:query, GraphQL::Batch::Setup)
  schema.instrument(:field, GraphQL::ActiveRecordBatcher::FieldInstrumenter.new)
})
