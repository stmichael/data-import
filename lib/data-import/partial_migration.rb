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

    def load_definitions_settings
      if File.exist? '.import_definitions'
        Marshal.load(File.new('.import_definitions'))
      else
        []
      end
    end
    private :load_definitions_settings

    def load_mappings_settings
      if File.exist? '.import_mappings'
        Marshal.load(File.new('.import_mappings'))
      else
        {}
      end
    end
    private :load_mappings_settings
  end
end
