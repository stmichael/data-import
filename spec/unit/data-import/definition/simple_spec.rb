require 'unit/spec_helper'

describe DataImport::Definition::Simple do

  let(:source) { stub }
  let(:target) { stub }
  subject { DataImport::Definition::Simple.new('a', source, target) }

  it 'takes one step per row to execute' do
    record_count = 376
    subject.source_table_name = 'tblHouses'
    source_columns = [:name, :location, :location2]
    subject.source_columns = source_columns
    source_distinct_columns = [:name, :location]
    subject.source_distinct_columns = source_distinct_columns

    source.should_receive(:count).with('tblHouses',
                                       :columns => source_columns,
                                       :distinct => source_distinct_columns).and_return(record_count)
    subject.total_steps_required.should == record_count
  end

  describe "#mappings" do
    it "returns an empty hash by default" do
      subject.mappings.should be_empty
    end
  end

  describe "#definition" do
    it "returns the definition of the importer if nothing is passed" do
      subject.definition.should == subject
    end

    it "looks for the definition in the registered definition list if a name is passed" do
      DataImport.stub(:definitions).and_return { {'abc' => :def} }
      subject.definition('abc').should == :def
    end

    it "raises an error if no definition was found" do
      DataImport.stub(:definitions).and_return { {} }
      lambda { subject.definition('abc') }.should raise_error
    end
  end

  describe '#run' do
    it 'executes the definition and displays the progress' do
      progress_reporter = stub
      importer = mock
      DataImport::Importer.should_receive(:new).with('CONTEXT', subject).and_return(importer)
      importer.should_receive(:run)
      progress_reporter.should_receive(:inc)

      subject.run('CONTEXT', progress_reporter)
    end
  end

end
