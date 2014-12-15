require 'ostruct'

module TestingMacros

  def in_memory_mapping(options = {}, &block)
    plan = DataImport::Dsl.define(options) do
      source 'sqlite:/'
      target 'sqlite:/'

      instance_eval &block
    end
    source_database = plan.definitions.first.source_database
    target_database = plan.definitions.first.target_database
    @source_database = source_database
    @target_database = target_database

    let(:plan) { plan }
    let(:source_database) { source_database }
    let(:target_database) { target_database }
    after do
      target_database.tables.each {|t| target_database[t].delete }
    end
  end

  def database_setup(&block)
    context = OpenStruct.new
    context.source = @source_database
    context.target = @target_database
    context.instance_eval(&block)
  end

end
