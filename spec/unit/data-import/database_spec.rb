require 'unit/spec_helper'
require 'stringio'

describe DataImport::Database do

  subject { DataImport::Database }

  class TestAdapter
  end

  describe ".connect" do
    let(:options) { {:database => 'example', :username => 'bob', :password => 'secret'} }
    let(:output) { StringIO.new }
    let(:sequel_db) { double }
    let(:connection) { double }
    before do
      @stdout = $stdout
      $stdout = output
    end
    after { $stdout = @stdout }
    it 'outputs deprecation warnings when called with an adapter name' do
      expect(Sequel).to receive(:connect).with(options).and_return(sequel_db)
      expect(sequel_db).to receive(:extension).with(:identifier_mangling)
      expect(sequel_db).to receive(:identifier_output_method=).with(:to_s)
      expect(DataImport::Database::Connection).to receive(:new).with(sequel_db).and_return(connection)
      subject.connect(:sequel, options)
      output.rewind
      expect(output.read).to eq("DEPRECATION WARNING: specifiying the :sequel adapter explicitly will be removed in future versions\n")
    end

    it "returns a connection object from the correct adapter" do
      expect(Sequel).to receive(:connect).with(options).and_return(sequel_db)
      expect(sequel_db).to receive(:extension).with(:identifier_mangling)
      expect(sequel_db).to receive(:identifier_output_method=).with(:to_s)
      expect(DataImport::Database::Connection).to receive(:new).with(sequel_db).and_return(connection)
      expect(subject.connect(options)).to eq(connection)
    end
  end

  describe DataImport::Database::Connection do
    let(:db) { double }
    subject { DataImport::Database::Connection.new(db) }

    it 'decorates the passed in database connection' do
      expect(db).to receive(:adapter_scheme)

      subject.adapter_scheme
    end
  end
end
