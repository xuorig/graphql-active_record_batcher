require_relative 'test_helper'

class FieldInstrumenterTest < Minitest::Test
  def test_no_queries
    # This should perform 3 queries since the top level
    # fields cat and secondCat are not batched:
    # 1: SELECT  "cats".* FROM "cats" WHERE "cats"."id" = ? LIMIT ?  [["id", 1]
    # 2: SELECT  "cats".* FROM "cats" WHERE "cats"."id" = ? LIMIT ?  [["id", 2]
    # 3: Association should be batched
    # SELECT "dogs".* FROM "dogs" WHERE "dogs"."cat_id" IN (1, 2)

    assert_queries(3) do
      FakeSchema::Schema.execute <<-GRAPHQL
        query {
          shop {
            allProducts {
              price
            }
          }
          anotherShop {
            allProducts {
              price
            }
          }
        }
      GRAPHQL
    end
  end

  def test_raises_an_argument_error_when_association_does_not_exist
    shop = GraphQL::ObjectType.define do
      name "Shop"
      model FakeSchema::Data::Shop

      field :products, !types[!FakeSchema::Product] do
        preloads(:productz)
      end
    end

    query = GraphQL::ObjectType.define do
      name "Query"
      field :shop, shop, resolve: ->(_, _, _) { FakeSchema::Data::Shop.find(1) }
    end

    exception = assert_raises(ArgumentError) do
      GraphQL::Schema.define do
        query query
        instrument(:field, GraphQL::ActiveRecordBatcher::FieldInstrumenter.new)
      end
    end

    assert_equal "No association `productz` on model `FakeSchema::Data::Product`", exception.message
  end

  def test_raises_an_argument_error_when_association_does_not_exist
    shop = GraphQL::ObjectType.define do
      name "Shop"
      model FakeSchema::Data::Shop

      field :products, !types[!FakeSchema::Product] do
        preloads [:products, :wat]
      end
    end

    query = GraphQL::ObjectType.define do
      name "Query"
      field :shop, shop, resolve: ->(_, _, _) { FakeSchema::Data::Shop.find(1) }
    end

    exception = assert_raises(ArgumentError) do
      GraphQL::Schema.define do
        query query
        instrument(:field, GraphQL::ActiveRecordBatcher::FieldInstrumenter.new)
      end
    end

    assert_equal "No association `wat` on model `FakeSchema::Data::Shop`", exception.message
  end

  def test_raises_an_error_when_no_model_is_set
    bad_shop = GraphQL::ObjectType.define do
      name "Shop"

      field :products, !types[!FakeSchema::Product] do
        preloads(:products)
      end
    end

    query = GraphQL::ObjectType.define do
      name "Query"
      field :shop, bad_shop, resolve: ->(_, _, _) { FakeSchema::Data::Shop.find(1) }
    end

    exception = assert_raises(StandardError) do
      GraphQL::Schema.define do
        query query
        instrument(:field, GraphQL::ActiveRecordBatcher::FieldInstrumenter.new)
      end
    end

    assert_equal "No ActiveRecord Model set on type Shop's metadata. Use `model(YourActiveRecordModel)` inside the type's definition", exception.message
  end

  def test_multiple_preloads
    # This should perform 4 queries since the top level
    # fields cat and secondCat are not batched:
    # 1: SELECT  "cats".* FROM "cats" WHERE "cats"."id" = ? LIMIT ?  [["id", 1]
    # 2: SELECT  "cats".* FROM "cats" WHERE "cats"."id" = ? LIMIT ?  [["id", 2]
    # 3: Association should be batched
    # SELECT "dogs".* FROM "dogs" WHERE "dogs"."cat_id" IN (1, 2)
    # SELECT "birds".* FROM "birds" WHERE "birds"."cat_id" IN (1, 2)

    assert_queries(4) do
      FakeSchema::Schema.execute <<-GRAPHQL
        query {
          shop {
            productsAndLocations
          }
          anotherShop {
            productsAndLocations
          }
        }
      GRAPHQL
    end
  end
end
