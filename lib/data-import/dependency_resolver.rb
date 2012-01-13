module DataImport
  class DependencyResolver

    def initialize(plan)
      @plan = plan
    end

    def resolve(run_only = nil)
      definition_order_by_name = []
      definitions_to_execute = definitions_for_execution(run_only)
      while definition_order_by_name.count < definitions_to_execute.count
        did_execute = false
        definitions_to_execute.each do |name|
          candidate = @plan.definition(name)
          next if definition_order_by_name.include?(name)
          if (candidate.dependencies - definition_order_by_name).blank?
            definition_order_by_name << name
            did_execute = true
          end
        end
        unless did_execute
          raise "something went wrong! Could not execute all necessary definitions: #{candidate.dependencies - @@executed_definitions}"
        end
      end
      ExecutionPlan.new(definition_order_by_name.map {|name| @plan.definition(name) })
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
        raise RuntimeError, "ciruclar dependencies: '#{name}' <-> '#{dep}'" if visited_definitions.include?(dep)
        dependencies(dep, visited_definitions + [name])
      end.flatten
      direct_dependencies + indirect_dependencies
    end
    private :dependencies


  end
end
