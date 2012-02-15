require 'unit/spec_helper'

describe DataImport::Dsl do

  let(:plan) { stub }

  context "class methods" do
    subject { DataImport::Dsl }

    describe ".evaluate_import_config" do
      it "executes the content of the config in a new DSL context" do
        File.stub(:read).and_return do
          <<-RUBY
          source 'sqlite:/'
          target 'sqlite:/'
          RUBY
        end
        DataImport::ExecutionPlan.should_receive(:new).and_return(plan)
        result = subject.evaluate_import_config('my_file')
        result.should == plan
      end
    end
  end

  context "instance methods" do
    subject { DataImport::Dsl.new(plan) }

    describe "#source" do
      it "creates a connection to the database" do
        DataImport::Database.should_receive(:connect).with(:options)
        subject.source :options
      end

      let(:source) { Object.new }
      it "sets the source" do
        DataImport::Database.stub(:connect).and_return { source }
        subject.source :options
        subject.source_database.should == source
      end

      it 'adds the before block to source database when specified' do
        my_filter = lambda {}
        DataImport::Database.stub(:connect).and_return { source }
        source.should_receive(:before_filter=).with(my_filter)
        plan = DataImport::Dsl.define do
          source 'sqlite:/'
          before_filter &my_filter
        end
      end
    end

    describe "#target" do
      it "creates a connection to the database" do
        DataImport::Database.should_receive(:connect).with(:options)
        subject.target :options
      end

      let(:target) { Object.new }
      it "sets the target" do
        DataImport::Database.stub(:connect).and_return { target }
        subject.target :options
        subject.target_database.should == target
      end
    end

    describe "#import" do
      it "adds a new import config to the import" do
        definition = stub(:reader= => true)
        DataImport::Definition::Simple.should_receive(:new).with('Import 5', nil, nil).and_return(definition)
        plan.should_receive(:add_definition).with(definition)
        subject.import('Import 5') {}
      end

      it "sets the source and target database in the definition" do
        subject.stub(:source_database).and_return { :source }
        subject.stub(:target_database).and_return { :target }

        definition = stub(:reader= => true)
        DataImport::Definition::Simple.should_receive(:new).with('a', :source, :target).and_return(definition)
        plan.should_receive(:add_definition).with(definition)

        subject.import('a') {}
      end

      it "executes the block in an import conext" do
        my_block = lambda {}
        import_dsl = stub
        definition = stub(:reader= => true)
        DataImport::Definition::Simple.should_receive(:new).with(any_args).and_return(definition)
        plan.should_receive(:add_definition).with(definition)
        DataImport::Dsl::Import.should_receive(:new).with(definition).and_return(import_dsl)

        import_dsl.should_receive(:instance_eval).with(&my_block)
        subject.import 'name', &my_block
      end

      it "sets a null reader by default" do
        definition = stub
        DataImport::Definition::Simple.should_receive(:new).with(any_args).and_return(definition)
        plan.should_receive(:add_definition).with(definition)
        definition.should_receive(:reader=).with(kind_of(DataImport::Sequel::NullReader))

        subject.import('a') {}
      end
    end
  end

end
