module DataImport
  class Definition
    module Lookup

      def initialize(*args)
        @lookup_table_configurations = {}
        @lookup_tables = {}
        super
      end

      def lookup_for(name, options = {})
        config = LookupTableConfig.new(name, options)
        if has_lookup_table_on?(config.attribute)
          raise ArgumentError, "lookup-table for column '#{config.attribute}' was already defined"
        else
          @lookup_table_configurations[config.attribute] = config
          @lookup_tables[config.name] = {}
        end
      end

      def row_imported(id, row)
        row.each do |attribute, value|
          if has_lookup_table_on?(attribute)
            add_lookup_value(attribute, value, id)
          end
        end
      end

      def identify_by(name, value)
        if has_lookup_table_named?(name)
          config = config_named(name)
          if config.ignore_case? && value
            value = value.downcase
          end
          lookup_table_named(name)[value]
        else
          raise ArgumentError, "no lookup-table defined named '#{name}'"
        end
      end

      def has_lookup_table_on?(attribute)
        !!config_for(attribute.to_sym)
      end

      def has_lookup_table_named?(name)
        @lookup_tables.has_key?(name.to_sym)
      end

      def add_lookup_value(attribute, value, id)
        return if value.blank?
        config = config_for(attribute)
        if config.ignore_case?
          value = value.downcase
        end
        lookup_table_named(config.name)[value] = id
      end
      private :add_lookup_value

      def config_for(attribute)
        @lookup_table_configurations[attribute]
      end
      private :config_for

      def config_named(name)
        @lookup_table_configurations.values.detect {|c| c.name == name}
      end
      private :config_for

      def lookup_table_named(name)
        @lookup_tables[name]
      end
      private :lookup_table_named

      class LookupTableConfig
        attr_accessor :name, :attribute

        def initialize(name, options = {})
          @name = name.to_sym
          @ignore_case = options.fetch(:ignore_case) { false }
          @attribute = if options.has_key?(:column)
                         options[:column].to_sym
                       else
                         @name
                       end
        end

        def for?(attribute)
          @attribute = attribute
        end

        def ignore_case?
          @ignore_case
        end
      end

    end
  end
end
