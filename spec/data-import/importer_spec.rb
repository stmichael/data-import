require 'spec_helper'

describe DataImport::Importer do

  let(:source) { stub }
  let(:target) { stub }
  let(:other_definition) { DataImport::Definition::Simple.new 'C', source, target }
  let(:definition) { DataImport::Definition::Simple.new 'A', source, target }
  let(:context) { stub }
  before { context.stub(:definition).with('C').and_return(other_definition) }
  subject { DataImport::Importer.new(context, definition) }

  describe "#run" do
    it "runs the import in a transaction" do
      definition.target_database.should_receive(:transaction)
      subject.run
    end

    it "call #import_row for each row" do
      definition.target_database.stub(:transaction).and_yield
      definition.source_database.stub(:each_row).and_yield(:a => :b).and_yield(:c => :d)

      subject.should_receive(:import_row).with(:a => :b)
      subject.should_receive(:import_row).with(:c => :d)
      subject.run
    end

    context 'after blocks' do
      before do
        definition.target_database.stub(:transaction).and_yield
        definition.source_database.stub(:each_row)
      end

      it "run after the data import" do
        executed = false
        definition.after_blocks << Proc.new do
          executed = true
        end

        subject.run
        executed.should == true
      end

      it "have access to other definitions" do
        found_definition = nil
        definition.after_blocks << Proc.new do |context|
          found_definition = context.definition('C')
        end

        subject.run
        found_definition.should == other_definition
      end

      it 'have access to the definition instance' do
        found_name = nil
        definition.after_blocks << Proc.new do
          found_name = name
        end

        subject.run
        found_name.should == 'A'
      end
    end
  end

  describe "#import_row" do
    it "executes the insertion" do
      definition.stub(:mappings).and_return { {:id => :id} }
      definition.stub(:target_table_name).and_return { :table }
      definition.target_database.should_receive(:insert_row).with(:table, :id => 1)
      subject.send(:import_row, :id => 1)
    end

    it "replaces the keys that occur in the field mapping" do
      definition.stub(:mappings).and_return { {:personenid => :id} }
      definition.stub(:target_table_name).and_return { :table }
      definition.target_database.should_receive(:insert_row).with(:table, :id => 1)
      subject.send(:import_row, :personenid => 1)
    end

    it "calls the proc if one is specified in the field mapping" do
      definition.stub(:mappings).and_return { {:personenid => lambda{|context, value| {:id => 2}}} }
      definition.stub(:target_table_name).and_return { :table }
      definition.target_database.should_receive(:insert_row).with(:table, :id => 2)
      subject.send(:import_row, :personenid => 1)
    end

    it "calls the proc for multiple columns" do
      definition.stub(:mappings).and_return { {[:a, :b] => lambda{|context, a_value, b_value| {:id => 2}}} }
      definition.stub(:target_table_name).and_return { :table }
      definition.target_database.should_receive(:insert_row).with(:table, :id => 2)
      subject.send(:import_row, :a => 4, :b => 9)
    end

    it "adds the generated id to the id mapping of the definition" do
      definition.target_database.stub(:insert_row).and_return { 15 }
      definition.stub(:source_primary_key).and_return { :id }
      definition.should_receive(:add_id_mapping).with(1 => 15)
      subject.send(:import_row, :id => 1)
    end

    it 'calls update_row for definitions with a mode uf :update' do
      definition.stub(:mappings).and_return { {:id => :id} }
      definition.target_table_name = 'target_table'
      definition.use_mode(:update)
      definition.target_database.should_receive(:update_row).with('target_table', {:id => 1})

      subject.send(:import_row, :id => 1)
    end
  end

end
