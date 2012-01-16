module DataImport
  module Sequel
    class Table < Dataset

      BATCH_SIZE = 1000

      def initialize(connection, table_name, options = {})
        @connection = connection
        @table_name = table_name
      end

      def base_query
        @connection.db.from(@table_name)
      end

    end
  end
end
