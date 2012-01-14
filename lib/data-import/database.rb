require 'sequel'
require 'iconv'

module DataImport
  class Database

    def self.connect(*args)
      options = if args.first == :sequel
                  puts "DEPRECATION WARNING: specifiying the :sequel adapter explicitly will be removed in future versions"
                  args.last
                else
                  args.first
                end
      options ||= {}
      ::Sequel.identifier_output_method = :to_s
      db = ::Sequel.connect(options)
      Connection.new(db)
    end

    class Connection
      attr_reader :db
      attr_accessor :before_filter

      def initialize(db)
        @db = db
      end

      def truncate(table)
        @db.from(table).delete
      end

      def transaction(&block)
        @db.transaction do
          yield block
        end
      end

      def each_row(table, options = {}, &block)
        if options[:primary_key].nil? || !numeric_column?(table, options[:primary_key])
          each_row_without_batches table, options, &block
        else
          each_row_in_batches table, options, &block
        end
      end

      def each_row_without_batches(table, options = {}, &block)
        sql = @db.from(table)
        sql = sql.select(*options[:columns]) unless options[:columns].nil?
        sql = sql.distinct if options[:distinct]
        sql = sql.order(*options[:order]) unless options[:order].nil?
        sql.each do |row|
          before_filter.call(row) if before_filter
          yield row if block_given?
        end
      end

      def each_row_in_batches(table, options = {}, &block)
        personen = @db.from(table)
        max = maximum_value(table, options[:primary_key]) || 0
        lower_bound = 0
        batch_size = 1000
        while (lower_bound <= max) do
          upper_bound = lower_bound + batch_size - 1
          sql = personen.filter(options[:primary_key] => lower_bound..upper_bound)
          sql = sql.select(*options[:columns]) unless options[:columns].nil?
          sql = sql.distinct if options[:distinct]
          sql = sql.order(*options[:order]) unless options[:order].nil?
          sql.each do |result|
            before_filter.call(result) if before_filter
            yield result if block_given?
          end unless sql.nil?
          lower_bound += batch_size
        end
      end

      def maximum_value(table, column)
        @db.from(table).max(column)
      end

      def count(table, options = {})
        sql = @db.from(table)
        sql = sql.select(*options[:columns]) unless options[:columns].nil?
        sql = sql.distinct if options[:distinct]
        sql.count
      end

      def insert_row(table, row)
        @db.from(table).insert(row)
      end

      def update_row(table, row)
        id = row.delete(:id) || row.delete('id')
        @db.from(table).filter(:id => id).update(row)
      end

      def numeric_column?(table, column)
        column_definition = @db.schema(table).select{|c| c.first == column}.first
        column_definition[1][:type] == :integer unless column_definition.nil?
      end

      def unique_row(table, key)
        @db.from(table)[:id => key]
      end
    end

  end
end
