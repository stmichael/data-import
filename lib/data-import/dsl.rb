require 'data-import/dsl/import'
require 'data-import/dsl/script'

module DataImport
  class Dsl
    class << self

      def evaluate_import_config(files)
        plan = DataImport::ExecutionPlan.new
        Array(files).each do |file|
          context = new(plan)
          context.instance_eval read_import_config(file), file
        end
        plan
      end

      def define(&block)
        plan = DataImport::ExecutionPlan.new
        context = new(plan)
        context.instance_eval &block
        plan
      end

      def read_import_config(file)
        File.read(file)
      end
      private :read_import_config

    end

    def initialize(plan)
      @plan = plan
    end

    def source_database
      @source_database || raise(MissingDatabaseError.new('source', caller[1]))
    end

    def target_database
      @target_database || raise(MissingDatabaseError.new('target', caller[1]))
    end

    def source(*args)
      @source_database = DataImport::Database.connect(*args)
    end

    def target(*args)
      @target_database = DataImport::Database.connect(*args)
    end

    def import(name, &block)
      definition = DataImport::Definition::Simple.new(name, source_database, target_database)
      @plan.add_definition(definition)

      Import.new(definition).instance_eval &block
    end

    def script(name, &block)
      definition = DataImport::Definition::Script.new(name, source_database, target_database)
      @plan.add_definition(definition)

      Script.new(definition).instance_eval &block
    end

    def before_filter(&block)
      @source_database.before_filter = block
    end
  end
end
