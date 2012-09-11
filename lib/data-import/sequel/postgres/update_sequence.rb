module DataImport
  module Sequel
    module Postgres
      module UpdateSequence
        def transaction(&block)
          super
          @connection.reset_primary_key_sequence(@table_name)
        end
      end
    end
  end
end
