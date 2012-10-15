class ExecutionContext

  attr_reader :progress_reporter

  def initialize(execution_plan, definition, progress_reporter)
    @execution_plan = execution_plan
    @definition = definition
    @progress_reporter = progress_reporter
  end

  def logger
    DataImport.logger
  end

  def definition(name)
    @execution_plan.definition(name)
  end

  def name
    @definition.name
  end

  def source_database
    @definition.source_database
  end

  def target_database
    @definition.target_database
  end

  def id_mapping_for(definition_name, mapping_name)
    @execution_plan.id_mapping_container.fetch(definition_name, mapping_name)
  end

  def id_mapping_container
    @execution_plan.id_mapping_container
  end

  class Proxy
    def initialize(context)
      @context = context
    end

    [:logger, :definition, :name, :source_database, :target_database, :id_mapping_for].each do |method_symbol|
      define_method method_symbol do |*args|
        @context.send(method_symbol, *args)
      end
    end
  end
end
