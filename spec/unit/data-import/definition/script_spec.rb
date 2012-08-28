require 'unit/spec_helper'

describe DataImport::Definition::Script do
  let(:source) { stub }
  let(:target) { stub }
  subject { described_class.new('a', source, target) }

  describe '#run' do
    let(:context) { stub(:name => 'ABC') }

    it 'execute the definition and displays the progress' do
      progress_reporter = stub
      found_name = nil
      subject.body = Proc.new { found_name = name }

      subject.run(context, progress_reporter)
      found_name.should == 'ABC'
    end
  end
end
