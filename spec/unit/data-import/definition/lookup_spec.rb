require 'unit/spec_helper'

describe DataImport::Definition::Lookup do

  let(:example_class) do
    Class.new do
      include DataImport::Definition::Lookup
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
        subject.row_imported(66, :undefined_attribute => 'value-to-lookup')
      end.should_not raise_error
    end

    it 'stores added mappings' do
      id = 17
      lookup_value = 'value-to-lookup'

      subject.row_imported(id, :code => lookup_value)

      subject.identify_by(:code, lookup_value).should == id
    end

    it 'allows to specify a column name different form the lookup name' do
      id = 9
      ref = 'i-am-a-reference'
      subject.lookup_for :reference, :column => 'strRef'

      subject.row_imported(id, :strRef => ref)

      subject.identify_by(:reference, ref).should == id
    end

    it 'raises an exception when trying accessing an undefined lookup-table' do
      lambda do
        subject.identify_by(:undefined_lookup_table, 'this-wont-work')
      end.should raise_error(ArgumentError, "no lookup-table defined named 'undefined_lookup_table'")
    end

    it 'do not add nil value mappings' do
      do_not_map_this_id = 6
      subject.row_imported(do_not_map_this_id, :code => nil)

      subject.identify_by(:code, nil).should == nil
    end
  end
end
