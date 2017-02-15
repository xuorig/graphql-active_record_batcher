$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'graphql/active_record_batcher'
require 'active_record'
require 'active_support'

require_relative 'support/fake_schema/schema'

require 'minitest/autorun'

ActiveRecord::Base.logger = Logger.new(STDOUT)

def assert_queries(num = 1, &block)
  queries  = []
  callback = lambda { |name, start, finish, id, payload|
    queries << payload[:sql] if payload[:sql] =~ /^SELECT|UPDATE|INSERT/
  }

  ActiveSupport::Notifications.subscribed(callback, "sql.active_record", &block)
ensure
  assert_equal num, queries.size, "#{queries.size} instead of #{num} queries were executed.#{queries.size == 0 ? '' : "\nQueries:\n#{queries.join("\n")}"}"
end
