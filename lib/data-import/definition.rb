require 'data-import/definition/simple'

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
  end
end
