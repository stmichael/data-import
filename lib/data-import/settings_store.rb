module DataImport
  class SettingsStore
    SETTINGS_FILE = '.import_settings'

    def save(data)
      File.open(SETTINGS_FILE, 'w') do |f|
        f << Marshal.dump(data)
      end
    end

    def load
      if File.exist?(SETTINGS_FILE)
        Marshal.load(File.new(SETTINGS_FILE))
      else
        {}
      end
    end
  end
end
