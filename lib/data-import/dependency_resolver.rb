module DataImport
  class DependencyResolver

    def initialize(plan)
      @plan = plan
    end

    def resolve(options = {})
      definitions_to_execute = definitions_for_execution(options[:run_only])
      resolved_plan = ExecutionPlan.new
      # TODO: refactor the before_filter away from the ExecutionPlan
      resolved_plan.before_filter = @plan.before_filter
      while resolved_plan.size < definitions_to_execute.size
        definitions_to_execute.each do |name|
          candidate = @plan.definition(name)
          next if resolved_plan.contains?(name)
          if resolved_plan.contains?(candidate.dependencies)
            resolved_plan.add_definition(candidate)
          end
        end
      end
      resolved_plan
    end

    def definitions_for_execution(run_only = nil)
      (run_only || @plan.definitions.map(&:name)).map do |name|
        [name] + dependencies(name)
      end.flatten.uniq
    end
    private :definitions_for_execution

    def dependencies(name, visited_definitions = [])
      definition = @plan.definition(name)
      direct_dependencies = definition.dependencies
      indirect_dependencies = direct_dependencies.map do |dep|
        raise CircularDependencyError.new(name, dep) if visited_definitions.include?(dep)
        dependencies(dep, visited_definitions + [name])
      end.flatten
      direct_dependencies + indirect_dependencies
    end
    private :dependencies


  end
end
