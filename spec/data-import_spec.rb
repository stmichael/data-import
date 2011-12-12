require 'spec_helper'

describe DataImport do

  subject { DataImport }

  describe ".run_definitions!" do
    let(:runner) { stub }
    let(:definitions) { [stub, stub] }

    it "can execute a configuration file" do
      configuration = stub(:definitions => definitions)
      DataImport::Dsl.should_receive(:evaluate_import_config).with('my_file').and_return(configuration)
      DataImport::Runner.should_receive(:new).with(definitions).and_return(runner)
      runner.should_receive(:run).with(:only => ['C'])

      subject.run_config! 'my_file', :only => ['C']
    end

    it "uses the DataImport::Runner to execute the definitions" do
      DataImport::Runner.should_receive(:new).with(definitions).and_return(runner)
      runner.should_receive(:run)

      subject.run_definitions!(definitions)
    end

    it "passes options to the runner" do
      DataImport::Runner.should_receive(:new).with(definitions).and_return(runner)
      runner.should_receive(:run).with(:only => ['A', 'B'])

      subject.run_definitions!(definitions, :only => ['A', 'B'])
    end
  end
end
