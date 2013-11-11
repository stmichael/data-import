module DataImport
  class ExecutionPlan
    attr_reader :id_mapping_container

    def initialize(definitions = [], id_mapping_container = nil)
      @definitions = Hash[definitions.map do |definition|
                            [definition.name, definition]
                          end]
      @id_mapping_container = id_mapping_container || Definition::IdMappingContainer.new
    end

    def add_definition(definition)
      @definitions[definition.name] = definition
    end

    def definitions
      @definitions.values
    end

    def definition(name)
      if @definitions.has_key?(name)
        @definitions[name]
      else
        raise MissingDefinitionError.new(name)
      end
    end
  end
end
