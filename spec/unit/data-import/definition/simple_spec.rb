require 'unit/spec_helper'

describe DataImport::Definition::Simple do

  let(:source) { double }
  let(:target) { double }
  subject { DataImport::Definition::Simple.new('a', source, target) }

  describe "#mappings" do
    it "returns an empty hash by default" do
      lambda do
        subject.mappings.next
      end.should raise_error(StopIteration)
    end
  end

  describe '#add_mapping' do
    it 'adds a mapping to the definition' do
      mapping = double
      subject.add_mapping(mapping)
      subject.mappings.next.should == mapping
    end
  end

  describe '#run' do
    it 'executes the definition and displays the progress' do
      importer = double
      DataImport::Definition::Simple::Importer.should_receive(:new).with('CONTEXT', subject).and_return(importer)
      importer.should_receive(:run)
      subject.run('CONTEXT')
    end
  end
end
