module DataImport
  class Runner

    def initialize(plan, progress_reporter = ProgressBar)
      @plan = plan
      @progress_reporter = progress_reporter
      @definitions = Hash[@plan.definitions.map do |definition|
                            [definition.name, definition]
                          end]

      @executed_definitions = []
    end

    def run(options = {})
      dependency_resolver = DependencyResolver.new(@plan.definitions)
      definitions_to_execute = dependency_resolver.resolve(options[:only])
      definitions_to_execute.each do |definition|
        bar = @progress_reporter.new(definition.name, definition.total_steps_required)
        definition.run(self, bar)
        bar.finish
      end
    end

    def definition(name)
      raise "no definition found for '#{name}'" unless @definitions[name].present?
      @definitions[name]
    end

    def before_filter
      @plan.before_filter
    end

  end
end
