module DataImport
  class Definition
    class Simple
      class Importer

        def initialize(context, definition, progress_reporter)
          @context = context
          @definition = definition
          @progress_reporter = progress_reporter
        end

        def run
          @definition.writer.transaction do
            @definition.reader.each_row do |row|
              import_row row
              @progress_reporter.inc
            end
            @definition.after_blocks.each do |block|
              @context.instance_exec(@context, &block)
            end
          end
        end

        def map_row(row)
          mapped_row = {}
          @definition.mappings.each do |mapping|
            mapping.apply!(@definition, @context, row, mapped_row)
          end
          mapped_row
        end

        def import_row(row)
          mapped_row = map_row(row)
          before_after_context = @context.build_local_context(:row => row, :mapped_row => mapped_row)

          if row_valid?(before_after_context)
            new_id = @definition.writer.write_row(mapped_row)
            @definition.row_imported(new_id, row)

            @definition.after_row_blocks.each do |block|
              before_after_context.instance_exec(before_after_context, row, mapped_row, &block)
            end
          end
        end

        def row_valid?(before_after_context)
          @definition.row_validation_blocks.all? do |block|
            before_after_context.instance_exec(before_after_context,
                                               before_after_context.row,
                                               before_after_context.mapped_row,
                                               &block)
          end
        end
        private :row_valid?
      end
    end
  end
end
