class ExecutionContext < OpenStruct
  def initialize(execution_plan, definition, values = {})
    super(values)
    @execution_plan = execution_plan
    @definition = definition
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

  def build_local_context(values)
    self.class.new(@execution_plan, @definition, values)
  end
end
