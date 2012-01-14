require 'unit/spec_helper'

describe DataImport::DependencyResolver do

  let(:stub_definition) {
    lambda { |name, *dependencies|
      dependency_names = dependencies.map {|dependency| dependency.is_a?(String) ? dependency : dependency.name}
      stub(name, :name => name, :dependencies => dependency_names)
    }
  }

  it 'can limit the definitions which should run' do
    a = stub_definition['A']
    b = stub_definition['B']
    c = stub_definition['C']

    resolver = DataImport::DependencyResolver.new(DataImport::ExecutionPlan.new([a, b, c]))
    resolver.resolve(:run_only => ['A', 'C']).definitions.map(&:name).should == ['A', 'C']
  end

  it 'executes leaf-definitions first and works to the top' do
    a = stub_definition['A']
    b = stub_definition['B']

    a_1 = stub_definition['A1', a]
    ab_1 = stub_definition['A-B-1', a, b]
    ab_a1_1 = stub_definition['AB-A1-1', ab_1, a_1]

    resolver = DataImport::DependencyResolver.new(DataImport::ExecutionPlan.new([ab_a1_1, ab_1, b, a, a_1]))

    resolver.resolve.definitions.map(&:name).should == ['A', 'B', 'A-B-1', 'A1', 'AB-A1-1']
  end

  it 'handles dependencies correctly when :only is present' do
    a = stub_definition['A']
    ab = stub_definition['AB', a]
    abc = stub_definition['ABC', a, ab]

    resolver = DataImport::DependencyResolver.new(DataImport::ExecutionPlan.new([abc, a, ab]))

    resolver.resolve(:run_only => ['ABC']).definitions.map(&:name).should == ['A', 'AB', 'ABC']
  end

  it "raises an exception when the dependencies can't be resolved" do
    a = stub_definition['A', 'B']
    b = stub_definition['B', 'A']
    resolver = DataImport::DependencyResolver.new(DataImport::ExecutionPlan.new([a, b]))

    lambda do
      resolver.resolve
    end.should raise_error(DataImport::CircularDependencyError)
  end

  it 'raises an error when invalid dependencies are found' do
    a = stub_definition['A', 'NOT_PRESENT']

    resolver = DataImport::DependencyResolver.new(DataImport::ExecutionPlan.new([a]))

    lambda do
      resolver.resolve
    end.should raise_error(DataImport::MissingDefinitionError)
  end

  it 'can resolve dependencies which appear to be circular but are not' do
    a = stub_definition['A']
    ab = stub_definition['AB', 'A']
    aba = stub_definition['AB-A', 'AB', 'A']

    resolver = DataImport::DependencyResolver.new(DataImport::ExecutionPlan.new([a, aba, ab]))

    resolver.resolve.definitions.map(&:name).should == ['A', 'AB', 'AB-A']
  end
end
