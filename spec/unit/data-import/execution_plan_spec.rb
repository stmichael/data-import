require 'unit/spec_helper'

describe DataImport::ExecutionPlan do

  let(:people) { stub(:name => 'People') }
  let(:houses) { stub(:name => 'House') }

  let(:definitions) { [people, houses] }

  it 'can be created with a set of definitions' do
    plan = DataImport::ExecutionPlan.new(definitions)
    plan.definitions.should == definitions
  end

  it 'definitions can be added' do
    subject.add_definition(people)
    subject.add_definition(houses)
    subject.definitions.should == [people, houses]
  end

  it 'stores the order the definitions were added' do
    cats = stub(:name => 'Cats')
    dogs = stub(:name => 'Dogs')
    plan = DataImport::ExecutionPlan.new(definitions)
    plan.add_definition(cats)
    plan.add_definition(dogs)
    plan.definitions.should == [people, houses, cats, dogs]
  end

  it 'can contain a before_filter' do
    my_filter = lambda {}
    subject.before_filter = my_filter
    subject.before_filter.should == my_filter
  end

  it 'definitions can be fetched by name' do
    subject.add_definition(people)
    subject.definition('People').should == people
  end

  it 'raises an error when a non-existing definition is fetched' do
    lambda do
      subject.definition('I-do-not-exist')
    end.should raise_error("no definition found for 'I-do-not-exist'")
  end

end
