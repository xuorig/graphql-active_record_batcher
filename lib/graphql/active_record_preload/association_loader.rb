require 'graphql/batch'

module GraphQL
  module ActiveRecordPreload
    class AssociationLoader < GraphQL::Batch::Loader
      def initialize(model, association)
        @model = model
        @association = association
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
    end
  end
end
