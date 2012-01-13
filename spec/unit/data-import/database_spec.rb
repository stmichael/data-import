require 'unit/spec_helper'
require 'stringio'

describe DataImport::Database do

  subject { DataImport::Database }

  class TestAdapter
  end

  describe ".connect" do
    let(:options) { {:database => 'example', :username => 'bob', :password => 'secret'} }
    let(:output) { StringIO.new }
    before do
      @stdout = $stdout
      $stdout = output
    end
    after { $stdout = @stdout }
    it 'outputs deprecation warnings when called with an adapter name' do
      DataImport::Adapters::Sequel.should_receive(:connect).with(options)
      subject.connect(:sequel, options)
      output.rewind
      output.read.should == "DEPRECATION WARNING: specifiying the :sequel adapter explicitly will be removed in future versions\n"
    end

    it "returns a connection object from the correct adapter" do
      DataImport::Adapters::Sequel.should_receive(:connect).with(options)
      subject.connect(options)
    end
  end

end
