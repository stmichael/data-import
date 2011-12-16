require 'spec_helper'

describe DataImport::Dsl::Import do

  let(:definition) { DataImport::Definition::Simple.new('d', :source, :target) }
  subject { DataImport::Dsl::Import.new(definition) }

  describe "#from" do
    it "saves the source table name to the definition" do
      subject.from 'source_table'
      definition.source_table_name.should == 'source_table'
    end

    it "saves the primary key" do
      subject.from 'source_table', :primary_key => 'my_key'
      definition.source_primary_key.should == :my_key
    end

    let(:block) { lambda{} }
    it "executes the passed block" do
      DataImport::Dsl::Import::From.any_instance.should_receive(:instance_eval).with(&block)
      subject.from &block
    end
  end

  describe "#to" do
    it "saves the target table name to the definition" do
      subject.to 'target_table'
      definition.target_table_name.should == 'target_table'
    end

    it 'accepts a :mode option' do
      subject.to 'target_table', :mode => :update
      definition.mode.should == :update
    end
  end

  describe "#dependencies" do
    it "sets the list of definitions it depends on" do
      subject.dependencies 'a', 'b'
      definition.dependencies.should == ['a', 'b']
    end

    it "can be called multiple times" do
      subject.dependencies 'a', 'b'
      subject.dependencies 'x'
      subject.dependencies 'y'
      definition.dependencies.should == ['a', 'b', 'x', 'y']
    end
  end

  describe "#mapping" do
    it "adds a column mapping to the definition" do
      subject.mapping :a => :b
      definition.mappings.should include(:a)
      definition.mappings[:a].should == :b
    end

    let(:block) { lambda{|value|} }
    it "adds a proc to the mappings" do
      subject.mapping :a, &block
      definition.mappings.should include(:a)
      definition.mappings[:a].should == block
    end

    it "adds a proc with multiple fields to the mappings" do
      subject.mapping :a, :b, &block
      definition.mappings.should include([:a, :b])
      definition.mappings[[:a, :b]].should == block
    end
  end

  describe "#after" do
    let(:block) { lambda{} }
    it "adds a proc to be executed after the import" do
      subject.after &block
      definition.after_blocks.should include(block)
    end
  end

  it "#after_row adds a block, which is executed after every row" do
    my_block = lambda {}
    subject.after_row &my_block
    definition.after_row_blocks == [my_block]
  end

end
