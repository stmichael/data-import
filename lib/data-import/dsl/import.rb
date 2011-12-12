module DataImport
  class Dsl
    class Import
      attr_reader :definition

      def initialize(definition)
        @definition = definition
      end

      def from(name = nil, options = {}, &block)
        definition.source_table_name = name
        definition.source_primary_key = options[:primary_key]

        From.new(definition).instance_eval &block if block_given?
      end

      def to(name, options = {})
        definition.target_table_name = name
        definition.use_mode(:update) if options[:mode] == :update
      end

      def mapping(*hash_or_symbols, &block)
        if hash_or_symbols.first.is_a? Hash
          definition.mappings.merge! hash_or_symbols.first
        else
          symbols = hash_or_symbols
          symbols = symbols.first if symbols.count == 1
          definition.mappings[symbols] = block
        end
      end

      def after(&block)
        definition.after_blocks << block
      end

      def dependencies(*dependencies)
        dependencies.each do |dependency|
          definition.add_dependency(dependency)
        end
      end

    end
  end
end
