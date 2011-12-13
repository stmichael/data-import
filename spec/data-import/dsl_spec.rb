require 'spec_helper'

describe DataImport::Dsl do

  context "class methods" do
    subject { DataImport::Dsl }
    let!(:dsl) { subject.new }

    describe ".evaluate_import_config" do
      it "executes the content of the config in a new DSL context" do
        subject.stub(:new).and_return { dsl }
        subject.stub(:read_import_config).and_return { 'config' }
        dsl.should_receive(:instance_eval).with('config', 'my_file')
        subject.evaluate_import_config('my_file')
      end
    end

    describe ".read_import_config" do
      it "returns the content of the config" do
        File.stub(:read).and_return { 'config' }
        subject.read_import_config('my_file').should == 'config'
      end
    end
  end

  context "instance methods" do
    subject { DataImport::Dsl.new }

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
        subject.import 'Import 5'
        subject.definitions.count.should == 1
        subject.definitions.first.should be_a(DataImport::Definition::Simple)
      end

      it "sets the source and target database in the definition" do
        subject.stub(:source_database).and_return { :source }
        subject.stub(:target_database).and_return { :target }
        subject.import 'a'
        subject.definitions.first.name.should == 'a'
        subject.definitions.first.source_database.should == :source
        subject.definitions.first.target_database.should == :target
      end

      let(:block) do
        lambda do
        end
      end
      it "executes the block in an import conext" do
        DataImport::Dsl::Import.any_instance.should_receive(:instance_eval).with(&block)
        subject.import 'name', &block
      end
    end
  end

end
