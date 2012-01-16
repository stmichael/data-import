require 'data-import/dsl/import'

module DataImport
  class Dsl
    class << self

      def evaluate_import_config(file)
        plan = DataImport::ExecutionPlan.new
        context = new(plan)
        context.instance_eval read_import_config(file), file
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

    attr_reader :source_database, :target_database

    def initialize(plan)
      @plan = plan
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

      Import.new(definition).instance_eval &block if block_given?
    end

    def before_filter(&block)
      @source_database.before_filter = block
    end
  end
end
