require 'unit/spec_helper'

describe DataImport::Definition do

  subject { DataImport::Definition.new('a', :source, :target) }

  it 'executes in 1 step' do
    subject.total_steps_required.should == 1
  end

  describe "#dependencies" do
    it "can have dependent definitions which must run before" do
      subject.add_dependency 'b'
      subject.add_dependency 'c'
      subject.dependencies.should == ['b', 'c']
    end
  end
end
