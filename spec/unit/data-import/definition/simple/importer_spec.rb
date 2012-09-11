require 'unit/spec_helper'

describe DataImport::Definition::Simple::Importer do

  let(:source) { stub }
  let(:target) { stub }
  let(:other_definition) { DataImport::Definition::Simple.new 'C', source, target }
  let(:definition) { DataImport::Definition::Simple.new 'A', source, target }
  let(:context) { stub(:name => 'A', :build_local_context => local_context) }
  let(:local_context) { stub }
  let(:progress_reporter) { stub }
  before { context.stub(:definition).with('C').and_return(other_definition) }
  subject { described_class.new(context, definition, progress_reporter) }

  describe "#run" do
    let(:reader) { mock }
    let(:writer) { mock }
    before { definition.stub(:reader => reader) }
    before { definition.stub(:writer => writer) }
    before { writer.stub(:transaction).and_yield }

    it "call #import_row for each row" do
      definition.reader.should_receive(:each_row).
        and_yield(:a => :b).
        and_yield(:c => :d)

      subject.should_receive(:import_row).with(:a => :b)
      subject.should_receive(:import_row).with(:c => :d)
      progress_reporter.should_receive(:inc).twice
      subject.run
    end

    context 'after blocks' do
      before do
        definition.reader.stub(:each_row)
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

    context 'validation' do
      let(:writer) { mock }
      before { definition.writer = writer }

      it 'validates data before insertion' do
        validated_rows = []
        validated_mapped_rows = []
        definition.row_validation_blocks << Proc.new do |context, row, mapped_row|
          validated_mapped_rows << mapped_row
          validated_rows << row
          true
        end

        subject.should_receive(:map_row).with({:id => 1}).and_return({:new_id => 1})
        local_context.should_receive(:row).and_return({:id => 1})
        local_context.should_receive(:mapped_row).and_return({:new_id => 1})
        writer.should_receive(:write_row).any_number_of_times

        subject.import_row(:id => 1)
        validated_mapped_rows.should == [{:new_id => 1}]
        validated_rows.should == [{:id => 1}]
      end

      it 'doesn\'t insert an invalid row' do
        definition.row_validation_blocks << Proc.new { false }

        local_context.should_receive(:row).and_return({:id => 1})
        local_context.should_receive(:mapped_row).and_return({:new_id => 1})
        writer.should_not_receive(:write_row)

        subject.import_row(:id => 1)
      end
    end
  end

  context 'after row blocks' do
    let(:writer) { mock }
    before { definition.writer = writer }
    it "run after the data import" do
      input_rows = []
      output_rows = []
      definition.after_row_blocks << Proc.new do |context, input_row, output_row|
        input_rows << input_row
        output_rows << output_row
      end

      subject.should_receive(:map_row).with({:id => 1}).and_return({:new_id => 1})
      subject.should_receive(:map_row).with({:id => 2}).and_return({:new_id => 2})
      writer.should_receive(:write_row).any_number_of_times
      subject.import_row(:id => 1)
      subject.import_row(:id => 2)

      input_rows.should == [{:id => 1}, {:id => 2}]
      output_rows.should == [{:new_id => 1}, {:new_id => 2}]
    end
  end

  context do
    let(:id_mapping) { mock }
    let(:name_mapping) { mock }
    let(:mappings) { [id_mapping, name_mapping] }
    let(:definition) { stub(:mappings => mappings,
                            :writer => writer,
                            :after_row_blocks => [],
                            :row_validation_blocks => []) }
    let(:writer) { mock }


    subject { described_class.new(context, definition, nil) }

    describe "#map_row" do
      it 'calls apply for all mappings' do
        legacy_row = {:legacy_id => 1, :legacy_name => 'hans'}
        id_mapping.should_receive(:apply!).with(definition, context, legacy_row, {})
        name_mapping.should_receive(:apply!).with(definition, context, legacy_row, {})
        subject.map_row(legacy_row).should == {}
      end
    end

    describe "#import_row" do
      let(:row) { {:id => 1} }
      before { subject.stub(:map_row => row) }

      it "executes the insertion" do
        writer.should_receive(:write_row).with({:id => 1})
        definition.stub(:row_imported)
        subject.import_row(row)
      end

      it "adds the generated id to the id mapping of the definition" do
        definition.writer.stub(:write_row).and_return(15)
        definition.should_receive(:row_imported).with(15, {:id => 1})
        subject.import_row(:id => 1)
      end
    end
  end

end
