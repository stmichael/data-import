require 'spec_helper'

describe DataImport::Dsl::Import::From do

  let(:definition) { DataImport::Definition::Simple.new('d', :source, :target) }
  subject { DataImport::Dsl::Import::From.new(definition) }

  describe "#table" do
    it "saves the source table name to the definition" do
      subject.table 'source_table'
      definition.source_table_name.should == 'source_table'
    end
  end

  describe "#primary_key" do
    it "saves the primary key to the definition" do
      subject.primary_key 'my_key'
      definition.source_primary_key.should == :my_key
    end
  end

  describe "#columns" do
    it "saves the columns to the definition" do
      subject.columns 'col1', 'col2'
      definition.source_columns.should include('col1')
      definition.source_columns.should include('col2')
    end

    it "sets the distinct flag" do
      subject.columns 'col1', :distinct => true
      definition.source_distinct_columns.should be_true
    end
  end

  describe "#order" do
    it "saves the order columns to the definition" do
      subject.order 'col1', 'col2'
      definition.source_order_columns.should include('col1')
      definition.source_order_columns.should include('col2')
    end
  end

end
