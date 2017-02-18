require 'promise.rb'
require 'graphql/batch'

module GraphQL
  module ActiveRecordBatcher
    class AssociationLoader < GraphQL::Batch::Loader
      def initialize(model, association)
        @model = model
        @association = association
      end

      def load(record)
        raise TypeError, "#{@model} loader can't load association for #{record.class}" unless record.is_a?(@model)
        return Promise.resolve(read_association(record)) if association_loaded?(record)
        super
      end

      # We want to load the associations on all records, even if they have the same id
      def cache_key(record)
        record.object_id
      end

      def perform(records)
        ::ActiveRecord::Associations::Preloader.new.preload(records, association)

        records.each do |record|
          association_result = record.public_send(association)
          fulfill(record, association_result)
        end
      end

      private

      attr_reader :model, :association

      def association_loaded?(record)
        puts record
        puts @association
        record.association(@association).loaded?
      end
    end
  end
end
