require 'data-import/definition/id_mapping_container'
require 'data-import/definition/mappings'
require 'data-import/definition/simple'
require 'data-import/definition/simple/importer'
require 'data-import/definition/script'

module DataImport
  class Definition
    attr_reader :name
    attr_reader :source_database, :target_database
    attr_reader :dependencies

    def initialize(name, source_database, target_database, id_mapping_container)
      @name = name
      @source_database = source_database
      @target_database = target_database
      @dependencies = []
      @id_mapping_container = id_mapping_container
    end

    def lookup_for(mapping_name, options = {})
      warn "[DEPRECATION] `definition(...).lookup_for(...)` is deprecated and will be removed in later versions! Use `lookup_for(...)` in import and script blocks instead instead.\n#{caller[0]}"

      attribute = options.fetch(:column) { mapping_name }

      if @id_mapping_container.has_dictionary_for?(name, mapping_name)
        raise ArgumentError, "lookup-table for column '#{attribute}' was already defined"
      else
        d = if options.fetch(:ignore_case) { false }
              CaseIgnoringDictionary.new
            else
              Dictionary.new
            end
        @id_mapping_container.add_dictionary(name, mapping_name, attribute, d)
      end
    end

    def row_imported(id, row)
      warn "[DEPRECATION] `definition(...).row_imported(...)` is deprecated and will be removed in later versions! Use `id_mapping_for(...).add(...)` instead.\n#{caller[0]}"

      @id_mapping_container.update_dictionaries(name, id, row)
    end

    def identify_by(mapping_name, value)
      warn "[DEPRECATION] `definition(...).identify_by(...)` is deprecated and will be removed in later versions! Use `id_mapping_for(...).lookup(...)` instead.\n#{caller[0]}"

      return if value.blank?
      if @id_mapping_container.has_dictionary_for?(name, mapping_name)
        @id_mapping_container.fetch(name, mapping_name).lookup(value)
      else
        raise ArgumentError, "no lookup-table defined named '#{name}'"
      end
    end

    def has_lookup_table_on?(name)
      @lookup_tables.has_key? name
    end
    private :has_lookup_table_on?

    def add_dependency(dependency)
      @dependencies << dependency
    end

    def total_steps_required
      1
    end
  end
end
