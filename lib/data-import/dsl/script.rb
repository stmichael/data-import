require 'data-import/dsl/dependencies'

module DataImport
  class Dsl
    class Script
      include Dependencies

      attr_reader :definition, :options

      def initialize(definition, options = {})
        @options = options
        @definition = definition
      end

      def body(&block)
        definition.body = block
      end
    end
  end
end
