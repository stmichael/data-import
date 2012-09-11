require 'delegate'
require 'sequel'

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

    class Connection < SimpleDelegator
      attr_accessor :before_filter

      def db
        warn "[DEPRECATION] `db` is deprecated and will be removed in later versions! Use sequel methods directly on the connection object instead.\n#{caller[0]}"
        self
      end
    end

  end
end
