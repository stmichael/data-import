module DataImport
  class Definition
    module Lookup
      def initialize(*args)
        @lookup_tables = {}
        super
      end

      def lookup_for(name, options = {})
        attribute = options.fetch(:column) { name }

        if has_lookup_table_on?(attribute)
          raise ArgumentError, "lookup-table for column '#{attribute}' was already defined"
        else
          @lookup_tables[name] = if options.fetch(:ignore_case) { false }
                                   CaseIgnoringTable.new(attribute)
                                 else
                                   Table.new(attribute)
                                 end
        end
      end

      def row_imported(id, row)
        row.each do |attribute, value|
          next if value.blank?
          add_lookup_value(attribute, value, id)
        end
      end

      def identify_by(name, value)
        return if value.blank?
        if has_lookup_table_named?(name)
          @lookup_tables[name].lookup(value)
        else
          raise ArgumentError, "no lookup-table defined named '#{name}'"
        end
      end

      def has_lookup_table_on?(attribute)
        @lookup_tables.values.any? { |t| t.for?(attribute) }
      end

      def has_lookup_table_named?(name)
        @lookup_tables.has_key?(name.to_sym)
      end

      def add_lookup_value(attribute, value, id)
        @lookup_tables.each do |_name, table|
          table.process(attribute, value, id)
        end
      end
      private :add_lookup_value

      class Table
        def initialize(attribute)
          @attribute = attribute.to_sym
          @mappings = {}
        end

        def for?(attribute)
          @attribute == attribute.to_sym
        end

        def process(attribute, key, id)
          if for?(attribute)
            add(key, id)
          end
        end

        def add(key, id)
          @mappings[key] = id
        end

        def lookup(key)
          @mappings[key]
        end
      end

      class CaseIgnoringTable < Table
        def add(key, id)
          super(key.downcase, id)
        end

        def lookup(key)
          super(key.downcase)
        end
      end

    end
  end
end
