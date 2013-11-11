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

    def to_hash
      @mappings
    end

    def empty?
      @mappings.empty?
    end

    def clear
      @mappings.clear
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
