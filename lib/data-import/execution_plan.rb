module DataImport
  class ExecutionPlan

    attr_accessor :before_filter

    def initialize(definitions = [])
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
      if contains?(name)
        @definitions[name]
      else
        raise MissingDefinitionError.new(name)
      end
    end

    def contains?(names)
      Array(names).all? do |name|
        @definitions.has_key?(name)
      end
    end

    def size
      @definitions.size
    end

  end
end
