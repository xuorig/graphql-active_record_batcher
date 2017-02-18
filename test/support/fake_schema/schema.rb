require 'test_helper'

module FakeSchema
  module Data
    # ActiveRecord::Base.logger = Logger.new(STDOUT)
    `rm -f ./_test_.db`
    # Set up "Bases" in ActiveRecord
    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "./_test_.db")

    ActiveRecord::Schema.define do
      self.verbose = false
      create_table :cats do |t|
        t.column :color, :string
      end
      create_table :dogs do |t|
        t.column :number_of_legs, :integer
        t.column :is_mean, :boolean
        t.column :cat_id, :integer
      end
      create_table :birds do |t|
        t.column :name, :string
        t.column :cat_id, :integer
      end
    end

    class Cat < ActiveRecord::Base
      has_many :dogs
      has_many :birds
    end

    class Dog < ActiveRecord::Base
    end

    class Bird < ActiveRecord::Base
    end

    cat1 = Cat.create!(color: 'white')
    cat2 = Cat.create!(color: 'black')

    Dog.create(number_of_legs: 3, is_mean: true, cat_id: cat1.id)
    Dog.create(number_of_legs: 4, is_mean: true, cat_id: cat1.id)
    Dog.create(number_of_legs: 1, is_mean: false, cat_id: cat2.id)

    Bird.create(name: 'burd', cat_id: cat1.id)
    Bird.create(name: 'berd', cat_id: cat2.id)
  end

  Query = GraphQL::ObjectType.define do
    name "Query"
    description "Da Query R00T"

    field :cat, Cat, resolve: ->(_, _, _) { Data::Cat.find(1) }
    field :secondCat, Cat, resolve: ->(_, _, _) { Data::Cat.find(2) }
  end

  Cat = GraphQL::ObjectType.define do
    name "Cat"
    description "A Cat"
    model Data::Cat

    field :color, !types.String
    field :dogFriends, !types[!Dog] do
      preloads(:dogs)
      resolve ->(cat, _, _) { cat.dogs }
    end

    field :preloadMany, !types.String do
      preloads [:dogs, :birds]
      resolve ->(cat, _, _) {
        cat.dogs
        cat.birds
        'ok'
      }
    end
  end

  Dog = GraphQL::ObjectType.define do
    name "Dog"
    description "A Dawg"
    model Data::Dog

    field :isMean, !types.Boolean, property: :is_mean
  end

  Schema = GraphQL::Schema.define do
    use_preloading

    query Query
  end
end
