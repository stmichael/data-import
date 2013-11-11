require 'unit/spec_helper'

describe DataImport::Dsl::Script do

  let(:source) { double }
  let(:target) { double }
  let(:definition) { DataImport::Definition::Script.new('s', source, target) }
  subject { described_class.new(definition) }

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

  describe '#body' do
    it 'assigns the body to the definition' do
      my_script = lambda {}

      subject.body &my_script
      definition.body.should == my_script
    end
  end

end
