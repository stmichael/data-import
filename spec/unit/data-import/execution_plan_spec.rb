require 'unit/spec_helper'

describe DataImport::ExecutionPlan do

  let(:people) { double(:name => 'People') }
  let(:houses) { double(:name => 'House') }
  let(:definitions) { [people, houses] }

  it 'can be created with a set of definitions' do
    plan = DataImport::ExecutionPlan.new(definitions)
    plan.definitions.should == definitions
  end

  it 'raises an error when a non-existing definition is fetched' do
    lambda do
      subject.definition('I-do-not-exist')
    end.should raise_error(DataImport::MissingDefinitionError)
  end

  it 'definitions can be added' do
    subject.add_definition(people)
    subject.add_definition(houses)
    subject.definitions.should == [people, houses]
  end

  context 'plan with definitions' do
    subject { DataImport::ExecutionPlan.new(definitions) }

    it 'stores the order the definitions were added' do
      cats = double(:name => 'Cats')
      dogs = double(:name => 'Dogs')
      subject.add_definition(cats)
      subject.add_definition(dogs)

      subject.definitions.should == [people, houses, cats, dogs]
    end

    it 'definitions can be fetched by name' do
      subject.definition('People').should == people
    end
  end

end
