require 'unit/spec_helper'

describe DataImport::ExecutionPlan do

  let(:people) { DataImport::Definition.new('People', :tblPerson, :people) }
  let(:houses) { DataImport::Definition.new('House', :tblHouse, :houses) }
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

  it 'can contain a before_filter' do
    my_filter = lambda {}
    subject.before_filter = my_filter
    subject.before_filter.should == my_filter
  end

end
