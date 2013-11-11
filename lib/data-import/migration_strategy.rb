module DataImport
  class MigrationStrategy
    attr_reader :completed_definitions, :settings_storage, :resolved_plan

    def initialize(plan, options = {}, progress_reporter = ProgressBar, settings_store = SettingsStore)
      @plan = plan
      @progress_reporter = progress_reporter
      @settings_storage = settings_store.new

      dependency_resolver = DependencyResolver.new(@plan)
      @resolved_plan = dependency_resolver.resolve(:run_only => options[:only])
      @resolved_plan.id_mapping_container.load(load_id_mappings)

      @completed_definitions = load_completed_definitions
    end

    def run
      definitions_to_migrate.each do |definition|
        run_definition(definition)

        completed_definitions << definition.name
        settings_storage.save(:completed_definitions => completed_definitions,
                              :id_mappings => resolved_plan.id_mapping_container.to_hash)
      end
    end

    def run_definition(definition)
      bar = @progress_reporter.new(definition.name, definition.total_steps_required)

      DataImport.logger.info "Starting to import \"#{definition.name}\""
      context = ExecutionContext.new(resolved_plan, definition, bar)
      definition.run context

      bar.finish
    end
    protected :run_definition
  end
end
