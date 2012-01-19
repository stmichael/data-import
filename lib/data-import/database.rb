require 'sequel'
require 'iconv'

Sequel.identifier_output_method = :to_s

module DataImport
  class Database

    def self.connect(*args)
      options = if args.first == :sequel
                  puts "DEPRECATION WARNING: specifiying the :sequel adapter explicitly will be removed in future versions"
                  args.last
                else
                  args.first
                end
      options ||= {}
      db = ::Sequel.connect(options)
      Connection.new(db)
    end

    class Connection
      attr_reader :db
      attr_accessor :before_filter

      def initialize(db)
        @db = db
      end

      def truncate(table)
        @db.from(table).delete
      end

      def transaction(&block)
        @db.transaction do
          yield block
        end
      end

      def update_row(table, row)
        id = row.delete(:id) || row.delete('id')
        @db.from(table).filter(:id => id).update(row)
      end
    end

  end
end
