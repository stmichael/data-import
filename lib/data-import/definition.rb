require 'data-import/definition/lookup'
require 'data-import/definition/mappings'
require 'data-import/definition/simple'
require 'data-import/definition/simple/importer'
require 'data-import/definition/script'

module DataImport
  class Definition
    attr_reader :name
    attr_reader :source_database, :target_database
    attr_reader :dependencies

    def initialize(name, source_database, target_database)
      @name = name
      @source_database = source_database
      @target_database = target_database
      @dependencies = []
    end

    def add_dependency(dependency)
      @dependencies << dependency
    end

    def total_steps_required
      1
    end
  end
end
