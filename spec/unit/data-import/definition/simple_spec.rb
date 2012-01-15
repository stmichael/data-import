require 'unit/spec_helper'

describe DataImport::Definition::Simple do

  let(:source) { stub }
  let(:target) { stub }
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
      mapping = stub
      subject.add_mapping(mapping)
      subject.mappings.next.should == mapping
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
