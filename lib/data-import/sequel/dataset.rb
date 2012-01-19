module DataImport
  module Sequel
    class Dataset

      BATCH_SIZE = 1000

      def initialize(connection, base_query_block)
        @connection = connection
        @base_query_block = base_query_block
      end

      def each_row(&block)
        iterate_dataset(selection, &block)
      end

      def selection
        base_query
      end

      def count
        base_query.count
      end

      def base_query
        @base_query_block.call(@connection.db)
      end

      def iterate_dataset(dataset, &block)
        dataset.each do |row|
          @connection.before_filter.call(row) if @connection.before_filter
          block.call(row)
        end
      end
      private :iterate_dataset
    end
  end
end
