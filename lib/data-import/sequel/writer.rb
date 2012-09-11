module DataImport
  module Sequel
    class Writer

      def initialize(connection, table_name)
        @connection = connection
        @table_name = table_name.to_sym
      end

      def transaction(&block)
        @connection.transaction(&block)
      end

      def write_row(row)
        raise NotImplementedError
      end

      def base_relation
        @connection.from(@table_name)
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

    class UniqueWriter < Writer
      def initialize(connection, table_name, options = {})
        super(connection, table_name)
        @options = options
      end

      def write_row(row)
        existing_row_id(row) || base_relation.insert(row)
      end

      def existing_row_id(row)
        unique_row = row.select{|k, v| @options[:columns].include?(k)}
        (base_relation.filter(unique_row).first || {})[:id]
      end
      private :existing_row_id
    end

  end
end
