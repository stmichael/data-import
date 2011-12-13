require 'spec_helper'

describe DataImport::Definition::Simple do

  subject { DataImport::Definition::Simple.new('a', :source, :target) }

  describe "#dependencies" do
    it "can have dependent definitions which must run before" do
      subject.add_dependency 'b'
      subject.add_dependency 'c'
      subject.dependencies.should == ['b', 'c']
    end
  end

  describe "#mappings" do
    it "returns an empty hash by default" do
      subject.mappings.should be_empty
    end
  end

  describe "#add_id_mapping" do
    it "adds a primary key mapping to the definition" do
      subject.add_id_mapping 18 => 24
      subject.id_mappings[18].should == 24
    end
  end

  describe "#new_id_of" do
    it "looks for the new id in the id mappings" do
      subject.add_id_mapping 39 => 834
      subject.new_id_of(39).should == 834
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
      Progress.should_receive(:start).with('Importing Houses', 125).and_yield
      importer = mock
      DataImport::Importer.should_receive(:new).with('CONTEXT', subject).and_return(importer)
      importer.should_receive(:run)

      subject.run('CONTEXT')
    end
  end

end
