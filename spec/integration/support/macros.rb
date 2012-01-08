require 'ostruct'

module TestingMacros

  def in_memory_mapping(&block)
    plan = DataImport::Dsl.define do
      source :sequel, 'sqlite:/'
      target :sequel, 'sqlite:/'

      instance_eval &block
    end
    source_database = plan.definitions.first.source_database.db
    target_database = plan.definitions.first.target_database.db
    @source_database = source_database
    @target_database = target_database

    let(:plan) { plan }
    let(:source_database) { source_database }
    let(:target_database) { target_database }
  end

  def database_setup(&block)
    context = OpenStruct.new
    context.source = @source_database
    context.target = @target_database
    context.instance_eval(&block)
  end

end
