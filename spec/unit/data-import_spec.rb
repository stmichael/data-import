require 'unit/spec_helper'

describe DataImport do

  subject { DataImport }

  describe ".run_definitions!" do
    let(:runner) { stub }
    let(:plan) { DataImport::ExecutionPlan.new(definitions) }
    let(:definitions) { [stub, stub] }

    it "can execute a configuration file" do
      DataImport::Dsl.should_receive(:evaluate_import_config).with('my_file').and_return(plan)
      DataImport::Runner.should_receive(:new).with(plan).and_return(runner)
      runner.should_receive(:run).with(:only => ['C'])

      subject.run_config! 'my_file', :only => ['C']
    end

    it "uses the DataImport::Runner to execute the plan" do
      DataImport::Runner.should_receive(:new).with(plan).and_return(runner)
      runner.should_receive(:run)

      subject.run_plan!(plan)
    end

    it "passes options to the runner" do
      DataImport::Runner.should_receive(:new).with(plan).and_return(runner)
      runner.should_receive(:run).with(:only => ['A', 'B'])

      subject.run_plan!(plan, :only => ['A', 'B'])
    end
  end

  describe 'configuration' do
    before { DataImport.lookup_table_directory = nil }
    it 'the directory for lookup-tables can be specified' do
      DataImport.lookup_table_directory = '/tmp'
      DataImport.lookup_table_directory.should == '/tmp'
      DataImport.persist_lookup_tables?.should be_true
    end

    it 'when no directory for the lookup-tables was specified they will not be persisted' do
      DataImport.persist_lookup_tables?.should be_false
    end
  end
end
