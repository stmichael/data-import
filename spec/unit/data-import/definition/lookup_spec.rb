# -*- coding: utf-8 -*-
require 'unit/spec_helper'

describe DataImport::Definition::Lookup do

  let(:definition_class) do
    Class.new do
      def setup; end
      def run; end
      def teardown; end
    end
  end
  let(:example_class) do
    Class.new(definition_class) do
      include DataImport::Definition::Lookup

      def name
        'Exämplé Definition'
      end
    end
  end

  subject { example_class.new }

  describe "lookup-table definition" do
    it 'knows what attributes have a lookup-table' do
      subject.lookup_for :code

      subject.has_lookup_table_on?(:code).should be_true
    end

    it 'knows what attributes do not have a lookup-table' do
      subject.lookup_for :code

      subject.has_lookup_table_on?(:oldID).should be_false
      subject.has_lookup_table_on?(:strRef).should be_false
      subject.has_lookup_table_on?(:abcd).should be_false
    end

    it 'allows to define lookup-tables with multiple calls' do
      subject.lookup_for :code
      subject.lookup_for :strRef

      subject.has_lookup_table_on?(:code).should be_true
      subject.has_lookup_table_on?(:strRef).should be_true
    end

    it 'works with strings' do
      subject.lookup_for 'a_string'

      subject.has_lookup_table_on?(:a_string).should be_true
    end

    it 'works with symbols' do
      subject.lookup_for :a_symbol

      subject.has_lookup_table_on?('a_symbol').should be_true
    end

    it 'should not allow to define two lookup-tables with the same name' do
      subject.lookup_for :code
      lambda do
        subject.lookup_for :code
      end.should raise_error(ArgumentError, "lookup-table for column 'code' was already defined")
    end

    it 'should not allow to define two lookup-tables for the same column' do
      subject.lookup_for :code
      lambda do
        subject.lookup_for :same_code, :column => :code
      end.should raise_error(ArgumentError, "lookup-table for column 'code' was already defined")
    end

  end

  describe 'mappings and lookups' do
    before { subject.lookup_for :code }

    it 'does not add any mappings when no lookup-attributes are given' do
      lambda do
        subject.add_mappings(66, :undefined_attribute => 'value-to-lookup')
      end.should_not raise_error
    end

    it 'stores added mappings' do
      id = 17
      lookup_value = 'value-to-lookup'

      subject.add_mappings(id, :code => lookup_value)

      subject.identify_by(:code, lookup_value).should == id
    end

    it 'allows to specify a column name different form the lookup name' do
      id = 9
      ref = 'i-am-a-reference'
      subject.lookup_for :reference, :column => 'strRef'

      subject.add_mappings(id, :strRef => ref)

      subject.identify_by(:reference, ref).should == id
    end

    it 'raises an exception when trying accessing an undefined lookup-table' do
      lambda do
        subject.identify_by(:undefined_lookup_table, 'this-wont-work')
      end.should raise_error(ArgumentError, "no lookup-table defined named 'undefined_lookup_table'")
    end

    it 'do not add nil value mappings' do
      do_not_map_this_id = 6
      subject.add_mappings(do_not_map_this_id, :code => nil)

      subject.identify_by(:code, nil).should == nil
    end
  end

  describe 'lookup-table persistance' do
    before do
      subject.lookup_for :code
      subject.add_mappings(1, :code => 'Milk Shake')
      subject.add_mappings(2, :code => 'Burger')
      subject.add_mappings(4, :code => 'Pizza')
    end

    let(:save_directory) { '/some/directory/example-definition' }
    let(:save_path) { '/some/directory/example-definition/code.json' }
    let(:lookup_table_hash) do
      {'Milk Shake' => 1, 'Burger' => 2, 'Pizza' => 4}
    end

    it 'clears the lookup-table before every run' do
      subject.run

      lambda do
        subject.identify_by(:code, 'Pizza').should_not == 4
      end.should raise_error(ArgumentError, "no lookup-table defined named 'code'")
    end

    before do
      DataImport.stub(:lookup_table_directory => '/some/directory')
    end

    context 'when lookup tables are not persisted' do
      before { DataImport.should_receive(:persist_lookup_tables?).any_number_of_times.and_return(false) }

      it 'does nothing' do
        File.should_not_receive(:write)
        File.should_not_receive(:read)

        subject.setup
        subject.teardown
      end
    end

    context 'when lookup tables get persisted' do
      before { DataImport.should_receive(:persist_lookup_tables?).any_number_of_times.and_return(true) }

      it 'saves the lookup-table when the definition ran' do
      FileUtils.should_receive(:mkdir_p).with(save_directory)
        JSON.should_receive(:dump).with(lookup_table_hash).and_return('the JSON')
        subject.should_receive(:write_json).with(save_path, 'the JSON')
        subject.teardown
      end

      context 'when the lookup-table was persisted' do
        before { File.should_receive(:exists?).with(save_path).and_return(true) }

        it 'loads the lookup-table when the definition is initialized' do
          File.should_receive(:read).
            with(save_path).
            and_return('the JSON')
          JSON.should_receive(:parse).with('the JSON').and_return(lookup_table_hash)

          subject.setup
          subject.identify_by(:code, 'Pizza').should == 4
        end
      end

      context 'when the lookup-table was not persisted' do
        before { File.should_receive(:exists?).with(save_path).and_return(false) }

        it 'skips the table' do
          subject.setup
        end
      end
    end

  end
end
