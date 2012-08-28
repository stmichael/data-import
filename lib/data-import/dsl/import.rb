require 'data-import/dsl/dependencies'

module DataImport
  class Dsl
    class Import
      include Dependencies

      attr_reader :definition

      def initialize(definition)
        @definition = definition
      end

      def from(table_name = nil, options = {}, &block)
        reader = if block_given?
                    DataImport::Sequel::Dataset.new(definition.source_database, block)
                  else
                    DataImport::Sequel::Table.new(definition.source_database, table_name, options)
                  end
        definition.reader = reader
      end

      def to(table_name, options = {})
        writer = if options[:mode] == :update
                   DataImport::Sequel::UpdateWriter.new(definition.target_database, table_name)
                 elsif options[:mode].kind_of?(Array) && options[:mode].first == :unique
                   DataImport::Sequel::UniqueWriter.new(definition.target_database, table_name, options[:mode].last)
                 else
                   DataImport::Sequel::InsertWriter.new(definition.target_database, table_name)
                 end
        if definition.target_database.adapter_scheme == :postgres
          writer.extend DataImport::Sequel::Postgres::UpdateSequence
        end
        definition.writer = writer
      end

      def mapping(*hash_or_symbols, &block)
        mapping = if hash_or_symbols.first.is_a? Hash
                    Definition::Simple::NameMapping.new(*hash_or_symbols.first.first)
                  else
                    check_block_arity(block)
                    Definition::Simple::BlockMapping.new(hash_or_symbols, block)
                  end
        definition.add_mapping(mapping)
      end

      def reference(name, options = {})
        lookup_name = options.delete(:lookup) || :id
        old_foreign_key = options.keys.first
        new_foreign_key = options[old_foreign_key]
        definition.add_mapping(Definition::Simple::ReferenceMapping.new(name, old_foreign_key, new_foreign_key, lookup_name))
      end

      def seed(seed_hash)
        mapping = Definition::Simple::SeedMapping.new(seed_hash)
        definition.add_mapping(mapping)
      end

      def after(&block)
        check_block_arity(block)
        definition.after_blocks << block
      end

      def after_row(&block)
        check_block_arity(block)
        definition.after_row_blocks << block
      end

      def validate_row(&block)
        check_block_arity(block)
        definition.row_validation_blocks << block
      end

      def check_block_arity(block)
        if block.arity > 0
          warn "[DEPRECATION] blocks with parameters are deprecated and will be removed in later versions!\n#{caller[1]}"
        end
      end
      private :check_block_arity

      def lookup_for(*attributes)
        definition.lookup_for(*attributes)
      end

    end
  end
end
