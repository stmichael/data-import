module DataImport
  class DependencyResolver

    def initialize(definitions)
      @definitions = Hash[definitions.map do |definition|
                            [definition.name, definition]
                          end]
    end

    def resolve(run_only = nil)
      definition_order_by_name = []
      definitions_to_execute = definitions_for_execution(run_only)
      while definition_order_by_name.count < definitions_to_execute.count
        did_execute = false
        definitions_to_execute.each do |name|
          candidate = definition(name)
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
      definition_order_by_name.map {|name| definition(name) }
    end

    def definition(name)
      raise "no definition found for '#{name}'" unless @definitions[name].present?
      @definitions[name]
    end
    private :definition

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
