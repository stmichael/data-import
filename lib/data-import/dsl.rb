require 'data-import/dsl/import'
require 'data-import/dsl/import/from'

module DataImport
  class Dsl
    class << self

      def evaluate_import_config(file)
        context = new
        context.instance_eval read_import_config(file), file
        context
      end

      def define(&block)
        context = new
        context.instance_eval &block
        context
      end

      def read_import_config(file)
        File.read(file)
      end

    end

    attr_reader :source_database, :target_database, :definitions

    def initialize
      @definitions = []
    end

    def source(*args)
      @source_database = DataImport::Database.connect(*args)
    end

    def target(*args)
      @target_database = DataImport::Database.connect(*args)
    end

    def import(name, &block)
      definition = DataImport::Definition.new(name, source_database, target_database)
      @definitions << definition

      Import.new(definition).instance_eval &block if block_given?
    end
  end
end
