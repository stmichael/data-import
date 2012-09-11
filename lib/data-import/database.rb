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
      attr_reader :db
      attr_accessor :before_filter

      def initialize(db)
        super
        @db = db
      end
    end

  end
end
