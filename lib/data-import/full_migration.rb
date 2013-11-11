module DataImport
  class FullMigration < MigrationStrategy
    def load_completed_definitions
      []
    end

    def load_id_mappings
      {}
    end

    def definitions_to_migrate
      resolved_plan.definitions
    end
  end
end
