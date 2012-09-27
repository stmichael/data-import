module DataImport
  class Definition
    class IdMappingContainer
      def initialize
        @mapping_configs = Hash.new {|hash, key| hash[key] = []}
      end

      def add_dictionary(definition_name, mapping_name, attribute, dictionary)
        @mapping_configs[definition_name] << IdMappingConfig.new(mapping_name, attribute, dictionary)
      end

      def fetch(definition_name, mapping_name)
        if has_dictionary_for?(definition_name, mapping_name)
          @mapping_configs[definition_name].detect {|config| config.name == mapping_name}.dictionary
        else
          raise MissingIdMappingError.new(mapping_name)
        end
      end

      def has_dictionary_for?(definition_name, mapping_name)
        @mapping_configs[definition_name].any? {|config| config.name == mapping_name}
      end

      def update_dictionaries(definition_name, new_id, row)
        @mapping_configs[definition_name].each do |config|
          next if row[config.attribute].blank?
          config.dictionary.add(row[config.attribute], new_id)
        end
      end

      class IdMappingConfig
        attr_reader :name, :attribute, :dictionary

        def initialize(name, attribute, dictionary)
          @name = name
          @attribute = attribute.to_sym
          @dictionary = dictionary
        end
      end
    end
  end
end
