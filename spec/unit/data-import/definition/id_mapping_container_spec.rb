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

    it 'clear all mapping data' do
      name_dictionary.should_receive(:clear)
      tag_dictionary.should_receive(:clear)

      subject.clear
    end

    it 'puts the dictionaries into a class independent format' do
      name_dictionary.should_receive(:to_hash).and_return({1 => 7})
      tag_dictionary.should_receive(:to_hash).and_return({6 => 2})

      subject.to_hash.should == {
        'Animals' => [
                      {:name => 'name',
                        :attribute => :name,
                        :mappings => {1 => 7}},
                      {:name => 'tagged animal',
                        :attribute => :tag,
                        :mappings => {6 => 2}}
                     ]}
    end

    it 'purges and loads the dictionaries from the exported format' do
      name_dictionary.should_receive(:clear).ordered
      tag_dictionary.should_receive(:clear).ordered
      name_dictionary.should_receive(:add).with(7, 8).ordered
      tag_dictionary.should_not_receive(:add)

      subject.load({
                     'Animals' => [
                                   {:name => 'name',
                                     :attribute => :name,
                                     :mappings => {7 => 8}},
                                   {:name => 'tagged animal',
                                     :attribute => :chip_id,
                                     :mappings => {6 => 3}}
                                  ]})
    end
  end
end
