require 'spec_helper'

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

      subject.lookup_table_on?(:code).should be_true
    end

    it 'knows what attributes do not have a lookup-table' do
      subject.lookup_for :code

      subject.lookup_table_on?(:oldID).should be_false
      subject.lookup_table_on?(:strRef).should be_false
      subject.lookup_table_on?(:abcd).should be_false
    end

    it 'allows to define multiple lookup-tables in one call' do
      subject.lookup_for :code, :oldID

      subject.lookup_table_on?(:code).should be_true
      subject.lookup_table_on?(:oldID).should be_true
    end

    it 'allows to define lookup-tables with multiple calls' do
      subject.lookup_for :code
      subject.lookup_for :strRef

      subject.lookup_table_on?(:code).should be_true
      subject.lookup_table_on?(:strRef).should be_true
    end

    it 'works with strings' do
      subject.lookup_for 'a_string'

      subject.lookup_table_on?(:a_string).should be_true
    end

    it 'works with symbols' do
      subject.lookup_for :a_symbol

      subject.lookup_table_on?('a_symbol').should be_true
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
      subject.add_mappings(id, :code => 'value-to-lookup')
      subject.identify_by(:code, 'value-to-lookup').should == id
    end
  end
end
