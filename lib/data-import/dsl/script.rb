require 'data-import/dsl/dependencies'
require 'data-import/dsl/lookup'

module DataImport
  class Dsl
    class Script
      include Dependencies
      include Lookup

      attr_reader :definition

      def initialize(definition, id_mapping_container)
        @definition = definition
        @id_mapping_container = id_mapping_container
      end

      def body(&block)
        definition.body = block
      end
    end
  end
end
