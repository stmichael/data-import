require 'unit/spec_helper'

describe DataImport::Definition::Simple do

  subject { DataImport::Definition::Simple.new('a', :source, :target) }

  describe "#mappings" do
    it "returns an empty hash by default" do
      subject.mappings.should be_empty
    end
  end

  describe "#definition" do
    it "returns the definition of the importer if nothing is passed" do
      subject.definition.should == subject
    end

    it "looks for the definition in the registered definition list if a name is passed" do
      DataImport.stub(:definitions).and_return { {'abc' => :def} }
      subject.definition('abc').should == :def
    end

    it "raises an error if no definition was found" do
      DataImport.stub(:definitions).and_return { {} }
      lambda { subject.definition('abc') }.should raise_error
    end
  end

  describe '#run' do

    let(:source_db) { mock }
    let(:target_db) { mock }
    let(:source_columns) { [:name, :location, :location2] }
    let(:source_distinct_columns) { [:name, :location] }

    subject do
      definition = DataImport::Definition::Simple.new('Houses', source_db, target_db)
      definition.source_table_name = 'tblHouses'
      definition.source_columns = source_columns
      definition.source_distinct_columns = source_distinct_columns
      definition
    end

    it 'executes the definition and displays the progress' do
      source_db.should_receive(:count).with('tblHouses',
                                            :columns => source_columns,
                                            :distinct => source_distinct_columns).and_return(125)
      progressbar = stub
      ProgressBar.should_receive(:new).with('Importing Houses', 125).and_return(progressbar)
      importer = mock
      DataImport::Importer.should_receive(:new).with('CONTEXT', subject).and_return(importer)
      importer.should_receive(:run)
      progressbar.should_receive(:inc)

      subject.run('CONTEXT')
    end
  end

end
