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

  describe '#execution_options' do
    before do
      subject.source_primary_key = :sHomeID
      subject.source_columns = [:sHomeID, :name, :location]
      subject.source_distinct_columns = [:name, :location]
      subject.source_order_columns = [:name]
    end

    it 'returns the options to query the source data' do
      subject.execution_options.should == {
        :primary_key => :sHomeID,
        :columns => [:sHomeID, :name, :location],
        :distinct => [:name, :location],
        :order => [:name]
      }
    end
  end

  describe '#run' do
    it 'executes the definition and displays the progress' do
      progress_reporter = stub
      importer = mock
      DataImport::Importer.should_receive(:new).with('CONTEXT', subject, progress_reporter).and_return(importer)
      importer.should_receive(:run)
      subject.run('CONTEXT', progress_reporter)
    end
  end

end
