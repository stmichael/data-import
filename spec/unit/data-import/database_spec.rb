require 'unit/spec_helper'
require 'stringio'

describe DataImport::Database do

  subject { DataImport::Database }

  class TestAdapter
  end

  describe ".connect" do
    let(:options) { {:database => 'example', :username => 'bob', :password => 'secret'} }
    let(:output) { StringIO.new }
    let(:sequel_db) { mock }
    let(:connection) { stub }
    before do
      @stdout = $stdout
      $stdout = output
    end
    after { $stdout = @stdout }
    it 'outputs deprecation warnings when called with an adapter name' do
      Sequel.should_receive(:connect).with(options).and_return(sequel_db)
      DataImport::Database::Connection.should_receive(:new).with(sequel_db).and_return(connection)
      subject.connect(:sequel, options)
      output.rewind
      output.read.should == "DEPRECATION WARNING: specifiying the :sequel adapter explicitly will be removed in future versions\n"
    end

    it "returns a connection object from the correct adapter" do
      Sequel.should_receive(:connect).with(options).and_return(sequel_db)
      DataImport::Database::Connection.should_receive(:new).with(sequel_db).and_return(connection)
      subject.connect(options).should == connection
    end
  end

end

describe DataImport::Database::Connection do
  let(:table) { Object.new }
  let(:dummy_db) do
    class DummyDB
    end
    DummyDB.any_instance.stub(:from).and_return { table }
    DummyDB
  end
  let(:db) { dummy_db.new }
  subject { DataImport::Database::Connection.new db }

  describe "#truncate" do
    it "deletes all rows from a table" do
      table.should_receive(:delete)
      subject.truncate('svp')
    end
  end

  describe "#transaction" do
    let(:block) { Proc.new {} }

    it "runs the block in a transaction" do
      db.should_receive(:transaction)
      subject.transaction &block
    end
  end

  describe "#insert_row" do
    it "inserts a single row into the database" do
      table.should_receive(:insert).with(:id => 29)
      subject.insert_row(:abc, :id => 29)
    end
  end

  describe "#update_row" do
    it 'updates the row with the given id' do
      filtered_records = stub
      table.should_receive(:filter).with(:id => 9).and_return(filtered_records)
      filtered_records.should_receive(:update).with(:name => 'Hans', :alter => 17)
      subject.update_row(:abc, {:id => 9, :name => 'Hans', :alter => 17})
    end

    it 'works with string keys' do
      filtered_records = stub
      table.should_receive(:filter).with(:id => 11).and_return(filtered_records)
      filtered_records.should_receive(:update).with('name' => 'Hans', 'alter' => 17)
      subject.update_row(:abc, {'id' => 11, 'name' => 'Hans', 'alter' => 17})
    end
  end
end
