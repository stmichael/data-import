require 'unit/spec_helper'

describe DataImport::ExecutionPlan do

  let(:people) { stub(:name => 'People') }
  let(:houses) { stub(:name => 'House') }
  let(:definitions) { [people, houses] }

  it 'can be created with a set of definitions' do
    plan = DataImport::ExecutionPlan.new(definitions)
    plan.definitions.should == definitions
  end

  it 'can contain a before_filter' do
    my_filter = lambda {}
    subject.before_filter = my_filter
    subject.before_filter.should == my_filter
  end

  it 'raises an error when a non-existing definition is fetched' do
    lambda do
      subject.definition('I-do-not-exist')
    end.should raise_error("no definition found for 'I-do-not-exist'")
  end

  context 'empty plan' do
    it 'should have a size of 0' do
      subject.size == 0
    end

    it 'definitions can be added' do
      subject.add_definition(people)
      subject.add_definition(houses)
      subject.definitions.should == [people, houses]
    end

    it 'does not contain any definitions' do
      subject.contains?('People').should be_false
      subject.contains?(['People', 'House']).should be_false
    end
  end

  context 'plan with definitions' do
    subject { DataImport::ExecutionPlan.new(definitions) }

    it 'the size is the amount of added definitions' do
      subject.size.should == 2
    end

    it 'stores the order the definitions were added' do
      cats = stub(:name => 'Cats')
      dogs = stub(:name => 'Dogs')
      subject.add_definition(cats)
      subject.add_definition(dogs)

      subject.definitions.should == [people, houses, cats, dogs]
    end

    it 'definitions can be fetched by name' do
      subject.definition('People').should == people
    end

    it 'contains a definition' do
      subject.contains?('People').should be_true
    end

    it 'contains multiple definitions' do
      subject.contains?(['People', 'House']).should be_true
    end
  end

end
