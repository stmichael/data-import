module DataImport
  class Database

    def self.connect(name, options = {})
      adapter = find_adapter(name)
      unless adapter.nil?
        adapter.connect options
      end
    end

    private

    SUPPORTED_ADAPTERS = [:sequel]

    def self.find_adapter(name)
      @@loaded_adapters ||= {}
      if SUPPORTED_ADAPTERS.include? name.to_sym
        if @@loaded_adapters[name.to_sym].nil?
          require "data-import/adapters/#{name.to_s}"
          class_name = name.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
          @@loaded_adapters[name.to_sym] = DataImport::Adapters.const_get(class_name)
        end
        @@loaded_adapters[name.to_sym]
      end
    end

  end
end
