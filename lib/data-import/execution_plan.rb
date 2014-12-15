module DataImport
  class ExecutionPlan
    attr_reader :options

    def initialize(definitions = [], options = {})
      @options = options
      @definitions = Hash[definitions.map do |definition|
                            [definition.name, definition]
                          end]
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
