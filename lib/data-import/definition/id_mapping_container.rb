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
          fetch_config(definition_name, mapping_name).dictionary
        else
          raise MissingIdMappingError.new(mapping_name)
        end
      end

      def fetch_config(definition_name, mapping_name)
        @mapping_configs[definition_name].detect {|config| config.name == mapping_name}
      end
      private :fetch_config

      def has_dictionary_for?(definition_name, mapping_name)
        @mapping_configs[definition_name].any? {|config| config.name == mapping_name}
      end

      def update_dictionaries(definition_name, new_id, row)
        @mapping_configs[definition_name].each do |config|
          next if row[config.attribute].blank?
          config.dictionary.add(row[config.attribute], new_id)
        end
      end

      def to_hash
        @mapping_configs.each_with_object({}) do |(definition_name, configs), result|
          result[definition_name] = configs.map(&:to_hash)
        end
      end

      def load(mapping_data)
        mapping_data.each do |definition_name, configs|
          configs.each do |config_data|
            config = fetch_config(definition_name, config_data[:name])
            if config.present? && config.attribute == config_data[:attribute]
              config.load(config_data[:mappings])
            end
          end
        end
      end

      class IdMappingConfig
        attr_reader :name, :attribute, :dictionary

        def initialize(name, attribute, dictionary)
          @name = name
          @attribute = attribute.to_sym
          @dictionary = dictionary
        end

        def to_hash
          {:name => name, :attribute => attribute, :mappings => dictionary.to_hash}
        end

        def load(mappings)
          mappings.each do |key, value|
            dictionary.add(key, value)
          end
        end
      end
    end
  end
end
