module DataImport
  class Definition
    class Simple
      class Importer

        def initialize(context, definition)
          @context = context
          @definition = definition
        end

        def run
          @definition.writer.transaction do
            @definition.reader.each_row do |row|
              import_row row
              @context.progress_reporter.inc
            end
            @definition.after_blocks.each do |block|
              @context.instance_exec(@context, &block)
            end
          end
        end

        def map_row(context, row)
          mapped_row = {}
          @definition.mappings.each do |mapping|
            mapping.apply!(@definition, context, row, mapped_row)
          end
          mapped_row
        end

        def import_row(row)
          row_context = Context.new(@context)
          row_context.row = row
          mapped_row = map_row(row_context, row)
          row_context.mapped_row = mapped_row

          if row_valid?(row_context)
            new_id = @definition.writer.write_row(mapped_row)
            @definition.row_imported(new_id, row)

            @definition.after_row_blocks.each do |block|
              row_context.instance_exec(row_context, row, mapped_row, &block)
            end
          end
        end

        def row_valid?(context)
          @definition.row_validation_blocks.all? do |block|
            context.instance_exec(context,
                                  context.row,
                                  context.mapped_row,
                                  &block)
          end
        end
        private :row_valid?
      end

      class Context < ExecutionContext::Proxy
        attr_accessor :row, :mapped_row
      end
    end
  end
end
