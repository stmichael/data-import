module DataImport
  class Dsl
    class Import
      class From

        attr_reader :definition

        def initialize(definition)
          @definition = definition
        end

        def table(name)
          definition.source_table_name = name
        end

        def primary_key(name)
          definition.source_primary_key = name
        end

        def columns(*args)
          if args.last.is_a? Hash
            options = args.pop
            definition.source_distinct_columns = options[:distinct]
          end
          definition.source_columns |= args
        end

        def order(*args)
          definition.source_order_columns |= args
        end

      end
    end
  end
end
