module DataImport
  module Sequel
    class NullReader
      def each_row
      end

      def count
        0
      end
    end
  end
end
