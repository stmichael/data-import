require 'integration/spec_helper'

describe DataImport::Sequel::Postgres::UpdateSequence do
  let(:table_name) { 'cities' }
  let(:connection) { DataImport::Database.connect('postgres://postgres@localhost/data_import_test') }
  subject { DataImport::Sequel::InsertWriter.new(connection, table_name) }

  before do
    db = connection.db
    db.create_table! :cities do
      primary_key :id
      String :name
    end

    subject.extend DataImport::Sequel::Postgres::UpdateSequence
  end

  it 'resets the primary key sequence' do
    subject.transaction do
      subject.write_row :id => 18
    end
    sequence_name = connection.db.primary_key_sequence(table_name)
    last_value = connection.db["SELECT last_value FROM #{sequence_name}"].first[:last_value]
    last_value.should == 19
  end
end
