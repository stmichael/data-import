module DataImport
  class Runner

    def initialize(plan)
      @plan = plan
    end

    def run(options = {})
      strategy = if options[:partial]
                   PartialMigration.new(@plan, options)
                 else
                   FullMigration.new(@plan, options)
                 end
      strategy.run
    end

  end
end
