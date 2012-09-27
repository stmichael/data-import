require 'unit/spec_helper'

describe DataImport::Dsl::Script do

  let(:source) { stub }
  let(:target) { stub }
  let(:container) { stub }
  let(:definition) { DataImport::Definition::Script.new('s', source, target, container) }
  subject { described_class.new(definition, container) }

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

  describe 'lookups' do
    let(:dictionary) { stub }

    it 'defines an id mapping' do
      DataImport::Dictionary.should_receive(:new).and_return(dictionary)
      container.should_receive(:add_dictionary).with('s', :name, :strName, dictionary)

      subject.lookup_for :name, :column => :strName
    end

    it 'defines an id mapping without explicitly setting the column' do
      DataImport::Dictionary.should_receive(:new).and_return(dictionary)
      container.should_receive(:add_dictionary).with('s', :name, :name, dictionary)

      subject.lookup_for :name
    end

    it 'defines an case insensitive id mapping' do
      DataImport::CaseIgnoringDictionary.should_receive(:new).and_return(dictionary)
      container.should_receive(:add_dictionary).with('s', :name, :name, dictionary)

      subject.lookup_for :name, :ignore_case => true
    end
  end
end
