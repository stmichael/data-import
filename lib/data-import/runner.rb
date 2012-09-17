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
        definition.run(ExecutionContext.new(resolved_plan, definition, :progress_reporter => bar), bar)

        bar.finish
      end
    end

  end
end
