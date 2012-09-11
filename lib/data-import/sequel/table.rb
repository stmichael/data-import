module DataImport
  module Sequel
    class Table < Dataset

      BATCH_SIZE = 1000

      def initialize(connection, table_name, options = {})
        @connection = connection
        @table_name = table_name
        @primary_key = options[:primary_key] && options[:primary_key].to_sym
      end

      def each_row(&block)
        if @primary_key.present? && primary_key_is_numeric?
          each_row_in_batches(&block)
        else
          super
        end
      end

      def selection
        query = base_query
        query = query.order(@primary_key) if @primary_key.present?
        query
      end

      def base_query
        @connection.from(@table_name)
      end

      def each_row_in_batches(&block)
        max = maximum_value(@primary_key) || 0
        lower_bound = 0
        while (lower_bound <= max) do
          upper_bound = lower_bound + BATCH_SIZE - 1

          dataset = selection.filter(@primary_key => lower_bound..upper_bound)
          iterate_dataset(dataset, &block)

          lower_bound += BATCH_SIZE
        end
      end
      private :each_row_in_batches

      def maximum_value(column)
        base_query.max(column.to_sym)
      end
      private :maximum_value

      def primary_key_is_numeric?
        selection.first[@primary_key].is_a?(Numeric)
      end
      private :primary_key_is_numeric?

    end
  end
end
