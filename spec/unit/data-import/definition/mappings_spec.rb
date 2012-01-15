require 'unit/spec_helper'

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

      context 'with an sterisk (*)' do
        subject { described_class.new('*', a_block) }
        let(:a_block) {
          lambda { |context, row|
            {:received_row => row}
          }
        }

        it 'passes the wole row to the block' do
          row = {:sLegacyID => 12, :strSomeName => 'John', :strSomeOtherString => 'Jane'}
          subject.apply(definition, context, row).should == {:received_row => row}
        end
      end
    end
  end
end
