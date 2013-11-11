require 'unit/spec_helper'

describe DataImport::Dsl::Import do

  let(:source) { double(:adapter_scheme => 'sqlite') }
  let(:target) { double }

  let(:definition) { DataImport::Definition::Simple.new('d', source, target) }
  subject { DataImport::Dsl::Import.new(definition) }

  describe "#from" do
    context 'when a table-name is passed' do
      it "assigns the source dataset to the definition" do
        reader = double
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

        reader = double
        DataImport::Sequel::Dataset.should_receive(:new).with(source, custom_dataset).and_return(reader)

        subject.from &custom_dataset
        definition.reader.should == reader
      end
    end
  end

  describe "#to" do
    let(:writer) { double('writer') }

    it "assigns a table-writer for the given table to the definition" do
      target.stub(:adapter_scheme)
      DataImport::Sequel::InsertWriter.should_receive(:new).with(target, 'tblChickens').and_return(writer)
      subject.to 'tblChickens'
      definition.writer.should == writer
    end

    it 'uses an UpdateWriter when the :mode is set to :update' do
      target.stub(:adapter_scheme)
      DataImport::Sequel::UpdateWriter.should_receive(:new).with(target, 'tblFoxes').and_return(writer)
      subject.to 'tblFoxes', :mode => :update
      definition.writer.should == writer
    end

    it 'extends the writer with the UpdateSequence module if the database is postgres' do
      target.stub(:adapter_scheme => :postgres)
      DataImport::Sequel::InsertWriter.stub(:new => writer)

      subject.to 'tblChickens'
      writer.should be_kind_of(DataImport::Sequel::Postgres::UpdateSequence)
    end

    it 'uses a UniqueWriter when the :mode is set to :unique' do
      target.stub(:adapter_scheme)
      DataImport::Sequel::UniqueWriter.should_receive(:new).with(target, 'tblAdresses', :columns => [:name, :gender]).and_return(writer)

      subject.to 'tblAdresses', :mode => [:unique, :columns => [:name, :gender]]
      definition.writer.should == writer
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

  describe 'mapping definitions' do
    describe "#mapping" do
      it "adds a column mapping to the definition" do
        name_mapping = double
        DataImport::Definition::Simple::NameMapping.should_receive(:new).with(:a, :b).and_return(name_mapping)
        definition.should_receive(:add_mapping).with(name_mapping)

        subject.mapping :a => :b
      end

      context 'legacy block mappings' do
        let(:block) { lambda{|value|} }
        it "adds a proc to the mappings" do
          block_mapping = double
          DataImport::Definition::Simple::BlockMapping.should_receive(:new).with([:a], block).and_return(block_mapping)
          definition.should_receive(:add_mapping).with(block_mapping)

          subject.mapping :a, &block
        end

        it "adds a proc with multiple fields to the mappings" do
          block_mapping = double
          DataImport::Definition::Simple::BlockMapping.should_receive(:new).with([:a, :b], block).and_return(block_mapping)
          definition.should_receive(:add_mapping).with(block_mapping)

          subject.mapping :a, :b, &block
        end

        it 'adds a proc with all fields to the mappings' do
          block_mapping = double
          DataImport::Definition::Simple::BlockMapping.should_receive(:new).with([:*], block).and_return(block_mapping)

          definition.should_receive(:add_mapping).with(block_mapping)

          subject.mapping :*, &block
        end
      end

      context 'wildcard block mappings' do
        let(:block) { lambda {} }
        it 'adds a proc with all fields to the mappings' do
          block_mapping = double
          DataImport::Definition::Simple::WildcardBlockMapping.should_receive(:new).with(block).and_return(block_mapping)

          definition.should_receive(:add_mapping).with(block_mapping)

          subject.mapping 'my complex mapping', &block
        end
      end
    end

    describe "#seed" do
      it 'adds a SeedMapping to the definition' do
        seed_hash = {:message => 'welcome', :source => 'migrated'}
        seed_mapping = double
        DataImport::Definition::Simple::SeedMapping.should_receive(:new).with(seed_hash).and_return(seed_mapping)
        definition.should_receive(:add_mapping).with(seed_mapping)

        subject.seed seed_hash
      end
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

  it '#validate_row adds a validation block' do
    validation_block = lambda {}
    subject.validate_row &validation_block
    definition.row_validation_blocks.should == [validation_block]
  end

end
