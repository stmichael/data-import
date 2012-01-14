module DataImport
  class Definition
    class Simple < Definition

      include Lookup

      attr_reader :source_primary_key
      attr_accessor :source_table_name, :source_columns, :source_distinct_columns, :source_order_columns
      attr_accessor :target_table_name
      attr_accessor :after_blocks, :after_row_blocks
      attr_reader :mode

      def initialize(name, source_database, target_database)
        super
        @mappings = []
        @mode = :insert
        @after_blocks = []
        @after_row_blocks = []
        @source_columns = []
        @source_order_columns = []
      end

      def mappings
        @mappings.to_enum
      end

      def add_mapping(mapping)
        @mappings << mapping
      end

      def source_primary_key=(value)
        @source_primary_key = value.to_sym unless value.nil?
      end

      def use_mode(mode)
        @mode = mode
      end

      def run(context, progress_reporter)
        Importer.new(context, self, progress_reporter).run
      end

      def total_steps_required
        source_database.count(source_table_name, count_options)
      end

      def execution_options
        count_options.merge(:primary_key => source_primary_key,
                            :order => source_order_columns)
      end

      def count_options
        {:columns => source_columns, :distinct => source_distinct_columns}
      end
      private :count_options

      class NameMapping
        def initialize(from, to)
          @from = from.to_sym
          @to = to.to_sym
        end

        def apply(_definition, _context, row)
          if row.has_key?(@from)
            { @to => row[@from]}
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
          arguments = [context] + @columns.map {|column| row[column] }
          definition.instance_exec(*arguments, &@block)
        end
      end

    end
  end
end
