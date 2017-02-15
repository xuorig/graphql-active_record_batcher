# Graphql::ActiveRecordBatcher

`GraphQL::ActiveRecordBatcher` is a toolkit to batch record loading as well as preload
active record association during GraphQL Execution.

It is meant to be use with the `graphql` gem and uses `graphql-batch` under the hood to
preload and batch external calls.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'graphql-active_record_batcher'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install graphql-active_record_batcher

## Usage

### Preloading Associations

Using GraphQL without preloading associations results in under performant API and
too many queries to the database. Take for example a Movie type which has a `characters` associations, and this GraphQL query:

```graphql
query {
  movie(id: "1") {
    characters {
      name
    }
  }
  movie(id: "2") {
    characters {
      name
    }
  }
}
```

This query would result in 4 calls to your database:

```sql
1: SELECT  "movies".* FROM "movies" WHERE "movies"."id" = ? LIMIT ?  [["id", 1]
2: SELECT  "movies".* FROM "movies" WHERE "movies"."id" = ? LIMIT ?  [["id", 2]
3: SELECT  "characters".* FROM "characters" WHERE "characters"."movie_id" = ? [["movie_id", 1]
4: SELECT  "characters".* FROM "characters" WHERE "characters"."movie_id" = ? [["movie_id", 2]
```

`GraphQL::ActiveRecordBatcher` lets you preload associations by using the `preload` definition during field definition:

```ruby
StarWarsMovie = GraphQL::ObjectType.define do
  name "StarWarsMovie"
  description "A StarWars Movie"

  # Define which active record model represents
  # the parent object
  model Movie

  field :characters, !types[!Dog] do
    preloads(:characters)
    resolve ->(movie, _, _) { movie.characters }
  end
end
```

Associations will now be preloaded and only 3 queries are used this time:

```sql
1: SELECT  "movies".* FROM "movies" WHERE "movies"."id" = ? LIMIT ?  [["id", 1]
2: SELECT  "movies".* FROM "movies" WHERE "movies"."id" = ? LIMIT ?  [["id", 2]
3: SELECT   "characters".* FROM "characters" WHERE "characters"."movie_d" IN (1, 2)
```

### Schema config

```ruby
Schema = GraphQL::Schema.define do
  query Query
  mutation Mutation

  # GraphQL Batch setup. Handle Promise objects.
  lazy_resolve(Promise, :sync)
  instrument(:query, GraphQL::Batch::Setup)

  # FieldInstrumenter takes care of preloading assocations you've
  # marked using the `preloads` attribute
  instrument(:field, GraphQL::ActiveRecordBatcher::FieldInstrumenter.new)
end
```

### TODO

  - [ ] Expose a way to batch finds
  - [ ] Expose a way or documentation on how to batch the `node` field
  - [ ] Accept an array of preloads
  - [ ] Accept nested preloads

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
