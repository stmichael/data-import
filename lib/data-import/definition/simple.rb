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
        @mode = :insert
        @after_blocks = []
        @after_row_blocks = []
        @source_columns = []
        @source_order_columns = []
      end

      def mappings
        @mappings ||= {}
      end

      def source_primary_key=(value)
        @source_primary_key = value.to_sym unless value.nil?
      end

      def definition(name = nil)
        if name.nil?
          self
        else
          DataImport.definitions[name] or raise ArgumentError
        end
      end

      def use_mode(mode)
        @mode = mode
      end

      def run(context, progress_reporter)
        Importer.new(context, self, progress_reporter).run
      end

      def total_steps_required
        source_database.count(source_table_name, execution_options)
      end

      def execution_options
        {:columns => source_columns, :distinct => source_distinct_columns}
      end
      private :execution_options

    end
  end
end
