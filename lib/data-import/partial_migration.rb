module DataImport
  class PartialMigration < MigrationStrategy
    def load_completed_definitions
      settings_storage.load[:completed_definitions] || []
    end

    def load_id_mappings
      settings_storage.load[:id_mappings] || {}
    end

    def definitions_to_migrate
      resolved_plan.definitions.reject {|definition| completed_definitions.include?(definition.name)}
    end
  end
end
