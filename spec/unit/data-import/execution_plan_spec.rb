require 'unit/spec_helper'

describe DataImport::ExecutionPlan do

  let(:people) { DataImport::Definition.new('People', :tblPerson, :people) }
  let(:houses) { DataImport::Definition.new('House', :tblHouse, :houses) }

  it 'kann mit einem Set von Definitions erstellt werden' do
    plan = DataImport::ExecutionPlan.new([people, houses])
    plan.definitions.should == [people, houses]
  end

  it 'beschreibt den Ablauf anhand von definitions' do
    subject.add_definition(people)
    subject.add_definition(houses)
    subject.definitions.should == [people, houses]
  end

  it 'kann einen before_filter enthalten' do
    my_filter = lambda {}
    subject.before_filter = my_filter
    subject.before_filter.should == my_filter
  end

end
