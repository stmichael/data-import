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

  describe DataImport::Database::Connection do
    describe "#adapter_scheme" do
      let(:db) { stub }
      subject { DataImport::Database::Connection.new(db) }

      it "delegates to db" do
        db.stub(:adapter_scheme => :postgres)
        subject.adapter_scheme.should == :postgres
      end
    end
  end
end
