module DataImport
  module Sequel
    class Writer

      def initialize(connection, table_name)
        @connection = connection
        @table_name = table_name
      end

      def transaction(&block)
        @connection.db.transaction(&block)
      end

      def write_row(row)
        raise NotImplementedError
      end

      def base_relation
        @connection.db.from(@table_name)
      end
    end

    class InsertWriter < Writer
      def write_row(row)
        base_relation.insert(row)
      end
    end

    class UpdateWriter < Writer
      def write_row(row)
        id = row.delete(:id) || row.delete('id')
        if id.present?
          base_relation.filter(:id => id).update(row)
          id
        else
          raise MissingIdError.new(row)
        end
      end
    end

  end
end
