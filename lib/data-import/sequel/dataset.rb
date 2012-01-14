module DataImport
  module Sequel
    class Dataset

      BATCH_SIZE = 1000

      def initialize(connection, base_query_block)
        @connection = connection
        @base_query_block = base_query_block
      end

      def each_row
        base_query.each_page(BATCH_SIZE) do |batch|
          batch.each do |row|
            @connection.before_filter.call(row) if @connection.before_filter
            yield row
          end
        end
      end

      def count
        base_query.count
      end

      def base_query
        @base_query_block.call(@connection.db)
      end


    end
  end
end
