module DataImport
  class Definition
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
