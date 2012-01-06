module DataImport
  class Definition
    module Lookup

      def initialize(*args)
        @lookup_table_attributes = []
        @lookup_tables = {}
        super
      end

      def lookup_for(*attributes)
        @lookup_table_attributes += attributes.map(&:to_sym)
      end

      def lookup_table_on?(attribute)
        @lookup_table_attributes.include?(attribute.to_sym)
      end

      def add_mappings(id, row)
        row.each do |key, value|
          if lookup_table_on?(key)
            lookup_table_for(key)[value] = id
          end
        end
      end

      def identify_by(attribute, value)
        lookup_table_for(attribute)[value]
      end

      def lookup_table_for(attribute)
        @lookup_tables[attribute] ||= {}
      end

    end
  end
end
