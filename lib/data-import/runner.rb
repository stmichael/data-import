require 'ostruct'

module DataImport
  class Runner

    def initialize(plan, progress_reporter = ProgressBar)
      @plan = plan
      @progress_reporter = progress_reporter
    end

    def run(options = {})
      dependency_resolver = DependencyResolver.new(@plan)
      resolved_plan = dependency_resolver.resolve(:run_only => options[:only])
      resolved_plan.definitions.each do |definition|
        bar = @progress_reporter.new(definition.name, definition.total_steps_required)

        DataImport.logger.info "Starting to import \"#{definition.name}\""
        definition.run(ExecutionContext.new(resolved_plan, definition), bar)

        bar.finish
      end
    end

    class ExecutionContext < OpenStruct
      def initialize(execution_plan, definition, values = {})
        super(values)
        @execution_plan = execution_plan
        @definition = definition
      end

      def logger
        DataImport.logger
      end

      def definition(name)
        @execution_plan.definition(name)
      end

      def name
        @definition.name
      end

      def source_database
        @definition.source_database
      end

      def target_database
        @definition.target_database
      end

      def build_local_context(values)
        self.class.new(@execution_plan, @definition, values)
      end
    end
  end
end
