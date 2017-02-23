require_relative 'test_helper'

class FieldInstrumenterTest < Minitest::Test
  def setup
    @model = FakeSchema::Data::Shop
    @shop = @model.first
    @type = FakeSchema::Shop
  end

  def test_field_resolves_to_a_promise
    field = GraphQL::ActiveRecordBatcher::Find.field(type: @type, model: @model)

    GraphQL::Batch.batch do
      assert field.resolve(nil, { id: @shop.id }, nil).is_a?(GraphQL::Batch::Promise)
    end
  end
end
