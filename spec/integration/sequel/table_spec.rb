require 'integration/spec_helper'

describe DataImport::Sequel::Table do

  let(:connection) { DataImport::Database.connect('sqlite:/') }
  let(:table_name) { :payments }

  before do
    connection.create_table table_name do
      primary_key :id
      Decimal :amount
      String :description
    end

    connection[table_name].insert(:id => 3, :amount => 100)
    connection[table_name].insert(:id => 4, :amount => 67.30)
    connection[table_name].insert(:id => 1002, :amount => 99.99)
    connection[table_name].insert(:id => 1, :amount => 20.95)
    connection[table_name].insert(:id => 5, :amount => 2.60)
    connection[table_name].insert(:id => 2, :amount => 9.90)
  end

  context 'with a primary key' do
    subject { described_class.new(connection, table_name, :primary_key => :id) }

    describe '#each_row' do
      it 'iterates over every row of the table' do
        yielded_ids = []
        subject.each_row do |row|
          yielded_ids << row[:id]
        end
        yielded_ids.should == [1, 2, 3, 4, 5, 1002]
      end
    end

    it '#count returns the total amount of records' do
      subject.count.should == 6
    end
  end

  context 'without a primary key' do
    subject { described_class.new(connection, table_name) }

    describe '#each_row' do
      it 'iterates over every row of the table' do
        yielded_ids = []
        subject.each_row do |row|
          yielded_ids << row[:id]
        end
        yielded_ids.should == [1, 2, 3, 4, 5, 1002]
      end
    end

    it '#count returns the total amount of records' do
      subject.count.should == 6
    end
  end
end
