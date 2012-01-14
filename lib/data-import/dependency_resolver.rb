module DataImport
  class DependencyResolver

    def initialize(plan, strategy = LoopStrategy)
      @plan = plan
      @strategy = strategy
    end

    def resolve(options = {})
      resolved_dependencies = @strategy.new(dependency_graph).call(options)
      resolved_dependencies = resolved_dependencies.map {|definition| @plan.definition(definition) }
      # TODO: Better way to deal with the ExecutionPlan copy
      plan = ExecutionPlan.new(resolved_dependencies)
      plan.before_filter = @plan.before_filter
      plan
    end

    def dependency_graph
      Hash[@plan.definitions.map do |definition|
             [definition.name, definition.dependencies]
           end]
    end
    private :dependency_graph

    class LoopStrategy
      def initialize(graph)
        @graph = graph
      end

      def call(options = {})
        definitions_to_execute = definitions_for_execution(options[:run_only])
        resolved_dependencies = []
        while resolved_dependencies.size < definitions_to_execute.size
          definitions_to_execute.each do |name|
            next if resolved_dependencies.include?(name)
            if (direct_dependencies(name) - resolved_dependencies).empty?
              resolved_dependencies << name
            end
          end
        end
        resolved_dependencies
      end

      def definitions_for_execution(run_only = nil)
        (run_only || @graph.keys).map do |name|
          [name] + recursive_dependencies(name)
        end.flatten.uniq
      end
      private :definitions_for_execution

      def direct_dependencies(name)
        if @graph.has_key?(name)
          @graph[name]
        else
          raise MissingDefinitionError.new(name)
        end
      end
      private :direct_dependencies

      def recursive_dependencies(name, visited_definitions = [])
        indirect_dependencies = direct_dependencies(name).map do |dep|
          raise CircularDependencyError.new(name, dep) if visited_definitions.include?(dep)
          recursive_dependencies(dep, visited_definitions + [name])
        end.flatten
        direct_dependencies(name) + indirect_dependencies
      end
      private :recursive_dependencies
    end
  end
end
