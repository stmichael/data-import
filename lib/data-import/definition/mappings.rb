module DataImport
  class Definition
    class NameMapping
      def initialize(from, to)
        @from = from.to_sym
        @to = to.to_sym
      end

      def apply!(_definition, _context, row, output_row)
        if row.has_key?(@from)
          output_row[@to] = row[@from]
        end
      end
    end

    class BlockMapping
      def initialize(columns, block)
        @columns = Array(columns).map(&:to_sym)
        @block = block
      end

      def apply!(definition, context, row, output_row)
        arguments = [context] + if @columns == [:*]
                                  [row]
                                else
                                  @columns.map {|column| row[column] }
                                end
        output_row.merge!(context.instance_exec(*arguments, &@block) || {})
      end

    end

    class WildcardBlockMapping
      def initialize(block)
        @block = block
      end

      def apply!(definition, context, row, output_row)
        output_row.merge!(context.instance_exec(context, row, &@block) || {})
      end
    end

    class ReferenceMapping
      def initialize(referenced_definition, old_foreign_key, new_foreign_key, lookup_name = :id)
        @referenced_definition = referenced_definition
        @old_foreign_key = old_foreign_key.to_sym
        @new_foreign_key = new_foreign_key.to_sym
        @lookup_name = lookup_name
      end

      def apply!(definition, context, row, output_row)
        output_row.merge!(@new_foreign_key => context.definition(@referenced_definition).identify_by(@lookup_name, row[@old_foreign_key]))
      end
    end

    class SeedMapping
      def initialize(seed_hash)
        @seed_hash = seed_hash
      end

      def apply!(_definition, _context, _row, output_row)
        output_row.merge!(@seed_hash)
      end
    end
  end
end
