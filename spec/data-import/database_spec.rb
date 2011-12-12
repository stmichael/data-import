require 'spec_helper'

describe DataImport::Database do

  subject { DataImport::Database }

  class TestAdapter
  end

  describe ".connect" do
    it "returns a connection object from the correct adapter" do
      subject.stub(:find_adapter).and_return { TestAdapter }
      TestAdapter.should_receive(:connect)
      subject.connect(:sequel)
    end
  end

  describe ".find_adapter" do
    it "returns nil if the adapter is not supported" do
      subject.send(:find_adapter, :abc).should be_nil
    end
  end

end
