require 'unit/spec_helper'

describe DataImport::Definition::IdMappingContainer do
  it 'raises an error if a dictionary cannot be found' do
    lambda do
      subject.fetch('Animals', 'gender')
    end.should raise_error(DataImport::MissingIdMappingError)
  end

  context 'with dictionaries' do
    let(:name_dictionary) { stub }
    let(:tag_dictionary) { stub }

    before do
      subject.add_dictionary('Animals', 'name', :name, name_dictionary)
      subject.add_dictionary('Animals', 'tagged animal', :tag, tag_dictionary)
    end

    it 'fetches an id dictionary' do
      subject.fetch('Animals', 'name').should == name_dictionary
    end

    it 'determines if a dictionary exists' do
      subject.has_dictionary_for?('Animals', 'name').should == true
      subject.has_dictionary_for?('People', 'name').should == false
    end

    it 'updates the id dictionaries when a row has benn imported' do
      name_dictionary.should_receive(:add).with('Lion', 5)
      tag_dictionary.should_not_receive(:add)

      subject.update_dictionaries('Animals', 5, {:name => 'Lion', :continent => 'Africa'})
    end
  end
end
