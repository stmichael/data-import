module DataImport
  class Definition
    class Simple < Definition

      include Lookup

      attr_accessor :target_table_name
      attr_accessor :reader, :writer
      attr_accessor :after_blocks, :after_row_blocks

      def initialize(name, source_database, target_database)
        super
        @mappings = []
        @mode = :insert
        @after_blocks = []
        @after_row_blocks = []
      end

      def mappings
        @mappings.to_enum
      end

      def add_mapping(mapping)
        @mappings << mapping
      end

      def run(context, progress_reporter)
        Importer.new(context, self, progress_reporter).run
      end

      def total_steps_required
        reader.count
      end

      class NameMapping
        def initialize(from, to)
          @from = from.to_sym
          @to = to.to_sym
        end

        def apply(_definition, _context, row)
          if row.has_key?(@from)
            { @to => row[@from] }
          else
            {}
          end
        end
      end

      class BlockMapping
        def initialize(columns, block)
          @columns = Array(columns).map(&:to_sym)
          @block = block
        end

        def apply(definition, context, row)
          arguments = [context] + if @columns == [:*]
                                    [row]
                                  else
                                    @columns.map {|column| row[column] }
                                  end
          definition.instance_exec(*arguments, &@block)
        end
      end

    end
  end
end
