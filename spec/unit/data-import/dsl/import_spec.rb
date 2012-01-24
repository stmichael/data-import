require 'unit/spec_helper'

describe DataImport::Dsl::Import do

  let(:source) { stub(:adapter_scheme => 'sqlite') }
  let(:target) { stub }

  let(:definition) { DataImport::Definition::Simple.new('d', source, target) }
  subject { DataImport::Dsl::Import.new(definition) }

  describe "#from" do
    context 'when a table-name is passed' do
      it "assigns the source dataset to the definition" do
        reader = stub
        DataImport::Sequel::Table.should_receive(:new).
          with(source, 'tblConversions', :primary_key => 'sID').
          and_return(reader)

        subject.from 'tblConversions', :primary_key => 'sID'
        definition.reader.should == reader
      end
    end

    context 'when a block is passed' do
      it 'uses the block to build the base query' do
        custom_dataset = lambda { |db| }

        reader = stub
        DataImport::Sequel::Dataset.should_receive(:new).with(source, custom_dataset).and_return(reader)

        subject.from &custom_dataset
        definition.reader.should == reader
      end
    end
  end

  describe "#to" do
    it "assigns a table-writer for the given table to the definition" do
      target.stub(:adapter_scheme)
      writer = stub
      DataImport::Sequel::InsertWriter.should_receive(:new).with(target, 'tblChickens').and_return(writer)
      subject.to 'tblChickens'
      definition.writer.should == writer
    end

    it 'uses an UpdateWriter when the :mode is set to :update' do
      target.stub(:adapter_scheme)
      writer = stub
      DataImport::Sequel::UpdateWriter.should_receive(:new).with(target, 'tblFoxes').and_return(writer)
      subject.to 'tblFoxes', :mode => :update
      definition.writer.should == writer
    end

    it 'extends the writer with the UpdateSequence module if the database is postgres' do
      target.stub(:adapter_scheme => :postgres)
      writer = stub
      DataImport::Sequel::InsertWriter.stub(:new => writer)

      subject.to 'tblChickens'
      writer.should be_kind_of(DataImport::Sequel::Postgres::UpdateSequence)
    end
  end

  describe "#dependencies" do
    it "sets the list of definitions it depends on" do
      subject.dependencies 'a', 'b'
      definition.dependencies.should == ['a', 'b']
    end

    it "can be called multiple times" do
      subject.dependencies 'a', 'b'
      subject.dependencies 'x'
      subject.dependencies 'y'
      definition.dependencies.should == ['a', 'b', 'x', 'y']
    end
  end

  describe "#mapping" do
    it "adds a column mapping to the definition" do
      name_mapping = stub
      DataImport::Definition::Simple::NameMapping.should_receive(:new).with(:a, :b).and_return(name_mapping)
      definition.should_receive(:add_mapping).with(name_mapping)

      subject.mapping :a => :b
    end

    let(:block) { lambda{|value|} }
    it "adds a proc to the mappings" do
      block_mapping = stub
      DataImport::Definition::Simple::BlockMapping.should_receive(:new).with([:a], block).and_return(block_mapping)
      definition.should_receive(:add_mapping).with(block_mapping)

      subject.mapping :a, &block
    end

    it "adds a proc with multiple fields to the mappings" do
      block_mapping = stub
      DataImport::Definition::Simple::BlockMapping.should_receive(:new).with([:a, :b], block).and_return(block_mapping)
      definition.should_receive(:add_mapping).with(block_mapping)

      subject.mapping :a, :b, &block
    end
  end

  describe "#after" do
    let(:block) { lambda{} }
    it "adds a proc to be executed after the import" do
      subject.after &block
      definition.after_blocks.should include(block)
    end
  end

  it "#after_row adds a block, which is executed after every row" do
    my_block = lambda {}
    subject.after_row &my_block
    definition.after_row_blocks == [my_block]
  end

end
