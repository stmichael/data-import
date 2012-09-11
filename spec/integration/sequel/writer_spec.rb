require 'integration/spec_helper'

describe DataImport::Sequel::Writer do
  let(:table_name) { 'cities' }
  let(:connection) { DataImport::Database.connect('sqlite:/') }

  before do
    connection.create_table :cities do
      primary_key :id
      String :name
    end
  end

  describe DataImport::Sequel::InsertWriter do
    subject { DataImport::Sequel::InsertWriter.new(connection, table_name) }

    it 'writes a row to the specified table' do
      subject.write_row(:id => 2, :name => 'Switzerland').should == 2
      connection[:cities].to_a.should == [{:id => 2, :name => "Switzerland"}]
    end

    it 'works with transactions' do
      subject.transaction do
        subject.write_row(:id => 2, :name => 'Switzerland').should == 2
      end
      connection[:cities].to_a.should have(1).item
    end
  end

  describe DataImport::Sequel::UpdateWriter do
    subject { DataImport::Sequel::UpdateWriter.new(connection, table_name) }

    before do
      connection[:cities].insert(:id => 5, :name => 'Schweiz')
    end

    it 'writes a row to the specified table' do
      subject.write_row(:id => 5, :name => 'Switzerland').should == 5
      connection[:cities].to_a.should == [{:id => 5, :name => "Switzerland"}]
    end

    it 'works with transactions' do
      subject.transaction do
        subject.write_row(:id => 5, :name => 'Switzerland').should == 5
      end
      connection[:cities].to_a.should have(1).item
    end


    it 'raises an error when no :id was in the row' do
      lambda do
        subject.write_row(:name => 'this will not work')
      end.should raise_error(DataImport::MissingIdError)
    end
  end

  describe DataImport::Sequel::UniqueWriter do
    subject { DataImport::Sequel::UniqueWriter.new(connection, table_name, :columns => [:name]) }

    it 'writes a row to the specified table' do
      subject.write_row(:id => 3, :name => 'Italy').should == 3
      connection[:cities].to_a.should == [{:id => 3, :name => 'Italy'}]
    end

    it 'works with transactions' do
      subject.transaction do
        subject.write_row(:id => 3, :name => 'Italy').should == 3
      end
      connection[:cities].to_a.should have(1).item
    end

    it 'doesn\'t write a record if a similar record exists' do
      connection[:cities].insert(:id => 6, :name => 'Spain')

      subject.write_row(:id => 2, :name => 'Spain').should == 6
      connection[:cities].to_a.should have(1).item
    end
  end

end
