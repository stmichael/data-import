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
      lambda do
        subject.mappings.next
      end.should raise_error(StopIteration)
    end
  end

  describe '#add_mapping' do
    it 'adds a mapping to the definition' do
      mapping = stub
      subject.add_mapping(mapping)
      subject.mappings.next.should == mapping
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

describe 'mappings' do

  describe DataImport::Definition::Simple::NameMapping do
    describe "#apply" do
      subject { described_class.new('sLegacyID', :id) }

      it '#apply changes the column name form <old> to <new> when applied' do
        subject.apply(nil, nil, {:sLegacyID => 5}).should == {:id => 5}
      end

      it '#apply returns an empty mapping when the mapped column is not present' do
        subject.apply(nil, nil, {:sOtherLegacyID => 5}).should == {}
      end
    end
  end

  describe DataImport::Definition::Simple::BlockMapping do
    let(:a_block) { lambda {} }

    describe "#apply" do
      let(:context) { stub }
      let(:definition) { stub }

      context 'with a single column' do
        let(:a_block) {
          lambda { |context, legacy_id|
            {:id_times_two => legacy_id * 2}
          }
        }
        subject { described_class.new('sLegacyID', a_block) }

        it 'calls the block with the column value' do
          subject.apply(definition, context, {:sLegacyID => 4}).should == {:id_times_two => 8}
        end
      end

      context 'with multiple column' do
        let(:a_block) {
          lambda { |context, legacy_id, name|
            {:result => "#{name}#{legacy_id * 4}"}
          }
        }

        subject { described_class.new([:sLegacyID, :strLegacyName], a_block) }

        it 'calls the block with the column values' do
          subject.apply(definition, context, {:sLegacyID => 3, :strLegacyName => 'Times four: '}).should == {:result => 'Times four: 12'}
        end
      end
    end
  end

end
