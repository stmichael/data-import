require 'data-import/dsl/dependencies'

module DataImport
  class Dsl
    class Script
      include Dependencies

      attr_reader :definition

      def initialize(definition)
        @definition = definition
      end

      def body(&block)
        definition.body = block
      end
    end
  end
end
