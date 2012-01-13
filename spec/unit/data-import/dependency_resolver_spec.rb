require 'unit/spec_helper'

describe DataImport::DependencyResolver do

  it 'can limit the definitions which should run' do
    a = DataImport::Definition.new 'A', :source, :target
    b = DataImport::Definition.new 'B', :source, :target
    c = DataImport::Definition.new 'C', :source, :target

    resolver = DataImport::DependencyResolver.new(DataImport::ExecutionPlan.new([a, b, c]))
    resolver.resolve(:run_only => ['A', 'C']).definitions.map(&:name).should == ['A', 'C']
  end

  it 'executes leaf-definitions first and works to the top' do
    a = DataImport::Definition.new 'A', :source, :target
    b = DataImport::Definition.new 'B', :source, :target

    a_1 = DataImport::Definition.new 'A1', :source, :target
    a_1.add_dependency('A')

    ab_1 = DataImport::Definition.new 'A-B-1', :source, :target
    ab_1.add_dependency('A')
    ab_1.add_dependency('B')

    ab_a1_1 = DataImport::Definition.new 'AB-A1-1', :source, :target
    ab_a1_1.add_dependency('A-B-1')
    ab_a1_1.add_dependency('A1')

    resolver = DataImport::DependencyResolver.new(DataImport::ExecutionPlan.new([ab_a1_1, ab_1, b, a, a_1]))

    resolver.resolve.definitions.map(&:name).should == ['A', 'B', 'A-B-1', 'A1', 'AB-A1-1']
  end

  it 'handles dependencies correctly when :only is present' do
    a = DataImport::Definition.new 'A', :source, :target
    ab = DataImport::Definition.new 'AB', :source, :target
    ab.add_dependency('A')
    abc = DataImport::Definition.new 'ABC', :source, :target
    abc.add_dependency('AB')

    resolver = DataImport::DependencyResolver.new(DataImport::ExecutionPlan.new([abc, a, ab]))

    resolver.resolve(:run_only => ['ABC']).definitions.map(&:name).should == ['A', 'AB', 'ABC']
  end

  it "raises an exception when the dependencies can't be resolved" do
    a = DataImport::Definition.new 'A', :source, :target
    b = DataImport::Definition.new 'B', :source, :target
    a.add_dependency('B')
    b.add_dependency('A')

    resolver = DataImport::DependencyResolver.new(DataImport::ExecutionPlan.new([a, b]))

    lambda do
      resolver.resolve
    end.should raise_error(RuntimeError, "ciruclar dependencies: 'B' <-> 'A'")
  end

  it 'raises an error when invalid dependencies are found' do
    a = DataImport::Definition.new 'A', :source, :target
    a.add_dependency('NOT_PRESENT')

    resolver = DataImport::DependencyResolver.new(DataImport::ExecutionPlan.new([a]))

    lambda do
      resolver.resolve
    end.should raise_error(RuntimeError, "no definition found for 'NOT_PRESENT'")
  end

  it 'can resolve dependencies which appear to be circular but are not' do
    a = DataImport::Definition.new 'A', :source, :target
    ab = DataImport::Definition.new 'AB', :source, :target
    ab.add_dependency('A')
    aba = DataImport::Definition.new 'AB-A', :source, :target
    aba.add_dependency('AB')
    aba.add_dependency('A')

    resolver = DataImport::DependencyResolver.new(DataImport::ExecutionPlan.new([a, aba, ab]))

    resolver.resolve.definitions.map(&:name).should == ['A', 'AB', 'AB-A']
  end
end
