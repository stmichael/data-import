require 'integration/spec_helper'

describe DataImport::Sequel::Dataset do
  let(:connection) { DataImport::Database.connect('sqlite:/') }
  let(:base_query) {
    lambda do |db|
      db.from(:payment_status, :payments).
        filter(:payments__status_id => :payment_status__id).
        order(:status_id)
    end
  }
  subject { described_class.new(connection, base_query) }

  before do
    connection.create_table :payments do
      primary_key :id
      Decimal :amount
      Integer :status_id
    end

    connection.create_table :payment_status do
      primary_key :id
      String :description
    end

    connection[:payment_status].insert(:id => 10, :description => 'open')
    connection[:payment_status].insert(:id => 11, :description => 'processing')
    connection[:payment_status].insert(:id => 12, :description => 'done')

    connection[:payments].insert(:id => 3, :amount => 100, :status_id => 10)
    connection[:payments].insert(:id => 4, :amount => 67.30, :status_id => 12)
    connection[:payments].insert(:id => 1, :amount => 20.95, :status_id => 12)
    connection[:payments].insert(:id => 5, :amount => 2.60, :status_id => 11)
    connection[:payments].insert(:id => 2, :amount => 9.90, :status_id => 10)
  end

  describe '#each_row' do
    it 'iterates over every row of the table' do
      yielded_ids = []
      subject.each_row do |row|
        yielded_ids << row[:id]
      end
      yielded_ids.should == [2, 3, 5, 1, 4]
    end
  end

  it '#count returns the total amount of records' do
    subject.count.should == 5
  end

  it 'uses the connections #before_filter' do
    connection.before_filter = lambda do |row|
      row[:description].upcase!
    end

    yielded_ids = []
    subject.each_row do |row|
      yielded_ids << row[:description]
    end

    yielded_ids.should == ['OPEN', 'OPEN', 'PROCESSING', 'DONE', 'DONE']
  end

end
