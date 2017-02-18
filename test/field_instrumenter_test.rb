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
          cat {
            dogFriends {
              isMean
            }
          }
          secondCat {
            dogFriends {
              isMean
            }
          }
        }
      GRAPHQL
    end
  end

  def test_raises_an_argument_error_when_association_does_not_exist
    bad_cat = GraphQL::ObjectType.define do
      name "Cat"
      model FakeSchema::Data::Cat

      field :dogs, !types[!FakeSchema::Dog] do
        preloads(:dogz)
      end
    end

    query = GraphQL::ObjectType.define do
      name "Query"
      field :cat, bad_cat, resolve: ->(_, _, _) { FakeSchema::Data::Cat.find(1) }
    end

    exception = assert_raises(ArgumentError) do
      GraphQL::Schema.define do
        query query
        instrument(:field, GraphQL::ActiveRecordBatcher::FieldInstrumenter.new)
      end
    end

    assert_equal "No association `dogz` on model `FakeSchema::Data::Cat`", exception.message
  end

  def test_raises_an_error_when_no_model_is_set
    bad_cat = GraphQL::ObjectType.define do
      name "Cat"

      field :dogs, !types[!FakeSchema::Dog] do
        preloads(:dogs)
      end
    end

    query = GraphQL::ObjectType.define do
      name "Query"
      field :cat, bad_cat, resolve: ->(_, _, _) { FakeSchema::Data::Cat.find(1) }
    end

    exception = assert_raises(StandardError) do
      GraphQL::Schema.define do
        query query
        instrument(:field, GraphQL::ActiveRecordBatcher::FieldInstrumenter.new)
      end
    end

    assert_equal "No ActiveRecord Model set on type Cat's metadata. Use `model(YourActiveRecordModel)` inside the type's definition", exception.message
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
          cat {
            preloadMany
          }
          secondCat {
            preloadMany
          }
        }
      GRAPHQL
    end
  end
end
