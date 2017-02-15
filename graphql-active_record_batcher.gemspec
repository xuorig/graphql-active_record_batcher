# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'graphql/active_record_batcher/version'

Gem::Specification.new do |spec|
  spec.name          = "graphql-active_record_batcher"
  spec.version       = GraphQL::ActiveRecordBatcher::VERSION
  spec.authors       = ["Marc-Andre Giroux"]
  spec.email         = ["mgiroux0@gmail.com"]

  spec.summary       = %q{Association Preloading and Query Batching for GraphQL}
  spec.description   = %q{Association Preloading and Query Batching for GraphQL}
  spec.homepage      = "http://mgiroux.me"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.10.1"
  spec.add_development_dependency "minitest-focus", "~> 1.1"
  spec.add_development_dependency "minitest-reporters", "~>1.0"
  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "byebug"

  spec.add_runtime_dependency "activerecord"
  spec.add_runtime_dependency "graphql"
  spec.add_runtime_dependency "graphql-batch"
  spec.add_runtime_dependency "promise.rb"
end
