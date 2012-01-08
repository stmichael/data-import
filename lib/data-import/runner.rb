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
      definitions_to_execute = definitions_for_execution(options[:only])
      while @executed_definitions.count < definitions_to_execute.count
        did_execute = false
        definitions_to_execute.each do |name|
          candidate = definition(name)
          next if @executed_definitions.include?(name)
          if (candidate.dependencies - @executed_definitions).blank?
            bar = @progress_reporter.new(name, candidate.total_steps_required)
            candidate.run(self, bar)
            bar.finish
            @executed_definitions << name
            did_execute = true
          end
        end

        unless did_execute
          raise "something went wrong! Could not execute all necessary definitions: #{candidate.dependencies - @@executed_definitions}"
        end
      end
    end

    def definition(name)
      raise "no definition found for '#{name}'" unless @definitions[name].present?
      @definitions[name]
    end

    def before_filter
      @plan.before_filter
    end

    def definitions_for_execution(run_only = nil)
      (run_only || @definitions.keys).map do |name|
        [name] + dependencies(name)
      end.flatten.uniq
    end
    private :definitions_for_execution

    def dependencies(name, visited_definitions = [])
      definition = definition(name)
      direct_dependencies = definition.dependencies
      indirect_dependencies = direct_dependencies.map do |dep|
        raise RuntimeError, "ciruclar dependencies: '#{name}' <-> '#{dep}'" if visited_definitions.include?(dep)
        dependencies(dep, visited_definitions + [name])
      end.flatten
      direct_dependencies + indirect_dependencies
    end
    private :dependencies


  end
end
