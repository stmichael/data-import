module DataImport
  class Definition
    module Lookup

      def initialize(*args)
        @lookup_table_configurations = {}
        @lookup_tables = {}

        super
      end

      def setup
        if DataImport.persist_lookup_tables?
          @lookup_tables.each_key do |table_name|
            path = File.join(lookup_table_persistance_directory, "#{table_name}.json")
            next unless File.exists?(path)
            json = File.read(path)
            @lookup_tables[table_name] = JSON.parse(json)
          end
        end

        super
      end

      def run
        @lookup_tables = {}
        super
      end

      def teardown
        if DataImport.persist_lookup_tables?
          FileUtils.mkdir_p(lookup_table_persistance_directory)
          @lookup_tables.each do |table_name, table|
            json = JSON.dump(table)
            path = File.join(lookup_table_persistance_directory, "#{table_name}.json")
            write_json(path, json)
          end
        end

        super
      end

      def lookup_table_persistance_directory
        File.join(DataImport.lookup_table_directory, name.parameterize)
      end
      private :lookup_table_persistance_directory

      def write_json(path, json)
        File.open(path, 'w+') {|f| f.write(json)}
      end
      private :write_json

      def lookup_for(name, options = {})
        config = LookupTableConfig.new(name, options)
        if has_lookup_table_on?(config.attribute)
          raise ArgumentError, "lookup-table for column '#{config.attribute}' was already defined"
        else
          @lookup_table_configurations[config.attribute] = config
          @lookup_tables[config.name] = {}
        end
      end

      def add_mappings(id, row)
        row.each do |attribute, value|
          if has_lookup_table_on?(attribute)
            add_mapping(attribute, value, id)
          end
        end
      end

      def identify_by(name, value)
        if has_lookup_table_named?(name)
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

      def add_mapping(attribute, value, id)
        return if value.blank?
        name = config_for(attribute).name
        lookup_table_named(name)[value] = id
      end
      private :add_mapping

      def config_for(attribute)
        @lookup_table_configurations[attribute]
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
          @attribute = if options.has_key?(:column)
                         options[:column].to_sym
                       else
                         @name
                       end
        end

        def for?(attribute)
          @attribute = attribute
        end
      end

    end
  end
end
