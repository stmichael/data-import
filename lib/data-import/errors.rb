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

  class MissingIdMappingError < RuntimeError
    MESSAGE = <<-ERROR
      no id mapping found for '%s'. possible reasons are:
        - you did not define '%s'
        - you executed a partial migration and forgot to add '%s' as a dependency
    ERROR

    def initialize(name)
      super(MESSAGE % [name, name, name])
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

  class MissingIdError < RuntimeError
    MESSAGE = <<-ERROR
      the mapped row did not contain an :id. This column is required for updates!
        - row: %s
    ERROR

    def initialize(*args)
      super(MESSAGE % args)
    end
  end

  class MissingDatabaseError < RuntimeError
    MESSAGE = <<-ERROR
      you didn't specify a %s database in the mapping file %s
ERROR

    def initialize(*args)
      super(MESSAGE % args)
    end
  end

end
