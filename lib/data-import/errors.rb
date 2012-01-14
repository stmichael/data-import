module DataImport
  class MissingDefinitionError < RuntimeError
    MESSAGE = <<-ERROR
      no definition found for '%s'. possible reasons are:
        - you did not define '%s'
        - you executed a partial migration and forgot to add '%s' as a dependency
    ERROR

    def initialize(definition)
      super(MESSAGE % [definition, definition, definition])
    end
  end

  class CircularDependencyError < RuntimeError
    MESSAGE = <<-ERROR
      circular dependencies for: '%s' <-> '%s'. possible reasons are:
        - you defined a dependency, which already defined you as a dependency
    ERROR

    def initialize(*args)
      super(MESSAGE % args)
    end
  end
end
