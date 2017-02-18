require 'test_helper'

module FakeSchema
  module Data
    # ActiveRecord::Base.logger = Logger.new(STDOUT)
    `rm -f ./_test_.db`
    # Set up "Bases" in ActiveRecord
    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "./_test_.db")

    ActiveRecord::Schema.define do
      self.verbose = false
      create_table :shops do |t|
        t.column :name, :string
      end
      create_table :products do |t|
        t.column :price, :integer
        t.column :shop_id, :integer
      end
      create_table :locations do |t|
        t.column :name, :string
        t.column :shop_id, :integer
      end
    end

    class Shop < ActiveRecord::Base
      has_many :products
      has_many :locations
    end

    class Product < ActiveRecord::Base
    end

    class Location < ActiveRecord::Base
    end

    shop1 = Shop.create!(name: 'My Lame Shop')
    shop2 = Shop.create!(name: 'My Cool Shop')

    Product.create(price: 50, shop_id: shop1.id)
    Product.create(price: 10, shop_id: shop1.id)
    Product.create(price: 100, shop_id: shop2.id)

    Location.create(name: 'Main Store', shop_id: shop1.id)
    Location.create(name: 'Popup Store', shop_id: shop2.id)
  end

  Query = GraphQL::ObjectType.define do
    name "Query"
    description "Da Query R00T"

    field :shop, Shop, resolve: ->(_, _, _) { Data::Shop.find(1) }
    field :anotherShop, Shop, resolve: ->(_, _, _) { Data::Shop.find(2) }
  end

  Shop = GraphQL::ObjectType.define do
    name "Shop"
    description "A Shop"
    model Data::Shop

    field :name, !types.String

    field :allProducts, !types[!Product] do
      preloads(:products)
      resolve ->(shop, _, _) { shop.products }
    end

    field :productsAndLocations, !types.String do
      preloads [:products, :locations]
      resolve ->(shop, _, _) {
        shop.products
        shop.locations
        'test'
      }
    end
  end

  Product = GraphQL::ObjectType.define do
    name "Product"
    description "A Product"
    model Data::Product

    field :price, !types.Int
  end

  Schema = GraphQL::Schema.define do
    use_preloading

    query Query
  end
end
