require 'integration/spec_helper'

describe DataImport::Sequel::Writer do
  let(:table_name) { 'cities' }
  let(:connection) { DataImport::Database.connect('sqlite:/') }

  before do
    db = connection.db
    db.create_table :cities do
      primary_key :id
      String :name
    end
  end

  describe DataImport::Sequel::InsertWriter do
    subject { DataImport::Sequel::InsertWriter.new(connection, table_name) }

    it 'writes a row to the specified table' do
      subject.write_row(:id => 2, :name => 'Switzerland').should == 2
      connection.db[:cities].to_a.should == [{:id => 2, :name => "Switzerland"}]
    end
  end

  describe DataImport::Sequel::UpdateWriter do
    subject { DataImport::Sequel::UpdateWriter.new(connection, table_name) }

    before do
      db = connection.db
      db[:cities].insert(:id => 5, :name => 'Schweiz')
    end

    it 'writes a row to the specified table' do
      subject.write_row(:id => 5, :name => 'Switzerland').should == 5
      connection.db[:cities].to_a.should == [{:id => 5, :name => "Switzerland"}]
    end

    it 'raises an error when no :id was in the row' do
      lambda do
        subject.write_row(:name => 'this will not work')
      end.should raise_error(DataImport::MissingIdError)
    end
  end

end
