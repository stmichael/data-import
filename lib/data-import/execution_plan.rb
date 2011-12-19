module DataImport
  class ExecutionPlan

    attr_reader :definitions
    attr_accessor :before_filter

    def initialize(definitions = [])
      @definitions = definitions
    end

    def add_definition(definition)
      @definitions << definition
    end

  end
end
