module DataImport
  class Dictionary
    def initialize
      @mappings = {}
    end

    def add(key, value)
      @mappings[key] = value
    end

    def lookup(key)
      @mappings[key]
    end
  end

  class CaseIgnoringDictionary < Dictionary
    def add(key, value)
      super(key.nil? ? nil : key.downcase, value)
    end

    def lookup(key)
      super(key.nil? ? nil : key.downcase)
    end
  end
end
