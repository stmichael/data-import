require 'unit/spec_helper'

require 'data-import/adapters/sequel'

describe DataImport::Adapters::Sequel do

  let(:table) { Object.new }
  let(:dummy_db) do
    class DummyDB
    end
    DummyDB.any_instance.stub(:from).and_return { table }
    DummyDB
  end
  let(:db) { dummy_db.new }
  subject { DataImport::Adapters::Sequel.new db }

  describe ".connect" do
    subject { DataImport::Adapters::Sequel }

    it "connects to the database" do
      Sequel.should_receive(:connect).with(:adapter => :test)
      subject.connect :adapter => :test
    end

    it "returns an instance of DataImport::Adapters::Sequel" do
      Sequel.stub(:connect)
      subject.connect.should be_a(DataImport::Adapters::Sequel)
    end
  end

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

  describe ".each_row" do
    it "delegates to .each_row_in_batches if there is a numeric primary key" do
      subject.stub(:numeric_column?).and_return { true }
      subject.should_receive(:each_row_in_batches).with(:abc, :primary_key => :PersonenID)
      subject.each_row(:abc, :primary_key => :PersonenID)
    end

    it "delegates to .each_row_without_batches if there is a primary key other than numeric" do
      subject.stub(:numeric_column?).and_return { false }
      subject.should_receive(:each_row_without_batches).with(:abc, :primary_key => :PersonenID)
      subject.each_row(:abc, :primary_key => :PersonenID)
    end

    it "delegates to .each_row_without_batches if there is no primary key" do
      subject.should_receive(:each_row_without_batches).with(:abc, {})
      subject.each_row(:abc)
    end
  end

  describe "#each_row_without_batches" do
    let(:resultset) { [:id => 2, :id => 4] }
    let(:proxy) { Object.new }

    it "selects all rows from the database" do
      db.stub_chain(:from, :each).and_return { proxy }
      db.should_receive(:from).with('Personen')
      subject.each_row_without_batches('Personen')
    end

    it "yields each item of the resultset" do
      db.stub_chain(:from, :each).and_yield(resultset[0])
        .and_yield(resultset[1])
      left_results = resultset.clone
      subject.each_row_without_batches('Personen') do |row|
        left_results.delete(row)
      end
      left_results.should be_empty
    end
  end

  describe "#each_row_in_batches" do
    it "gets the maximum id" do
      subject.should_receive(:maximum_value)
      table.stub(:filter)
      subject.each_row_in_batches('abc', :primary_key => :PersonenID)
    end

    it "selects batches of a fixed size" do
      subject.stub(:maximum_value).and_return { 2000 }
      table.stub(:filter)
      table.should_receive(:filter).with(:PersonenID => 0..999)
      table.should_receive(:filter).with(:PersonenID => 1000..1999)
      subject.each_row_in_batches('abc', :primary_key => :PersonenID)
    end
  end

  describe "#maximum_value" do
    it "selects the maximum value of a column" do
      table.should_receive(:max).with(:PersonenID)
      subject.maximum_value('abc', :PersonenID)
    end
  end

  describe "#count" do
    it "returns the amount of rows of a table" do
      table.should_receive(:count)
      subject.count('abc')
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

  describe "numeric_column?" do
    it "returns true for numbers" do
      db.stub(:schema).and_return { [[:id, {:type => :integer}]] }
      subject.numeric_column?(:table, :id).should be_true
    end

    it "returns false for other column types" do
      db.stub(:schema).and_return { [[:id, {:type => :string}]] }
      subject.numeric_column?(:table, :id).should be_false
    end
  end

  describe "#unique_row" do
    it "returns a row by its key" do
      db.stub_chain(:from, :[]).and_return { {:id => 5, :a => 7} }
      subject.unique_row(:table, 5).should == {:id => 5, :a => 7}
    end
  end

end
