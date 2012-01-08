require 'unit/spec_helper'

describe DataImport::Runner do

  let(:mock_progress_class) do
    Class.new do
      def initialize(name, total_steps); end

      def finish; end
    end
  end

  context 'with simple definitions' do
    let(:people) { DataImport::Definition.new('People', 'tblPerson', 'people') }
    let(:animals) { DataImport::Definition.new('Animals', 'tblAnimal', 'animals') }
    let(:articles) { DataImport::Definition.new('Articles', 'tblNewsMessage', 'articles') }
    let(:plan) { DataImport::ExecutionPlan.new }
    before do
      plan.add_definition(articles)
      plan.add_definition(people)
      plan.add_definition(animals)
    end

    subject { DataImport::Runner.new(plan, mock_progress_class) }

    it 'runs a set of definitions' do
      articles.should_receive(:run)
      people.should_receive(:run)
      animals.should_receive(:run)

      subject.run
    end

    it ":only limits the definitions, which will be run" do
      people.should_receive(:run)
      articles.should_receive(:run)

      subject.run :only => ['People', 'Articles']
    end
  end

  context "dependent definitions" do
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

      plan = DataImport::ExecutionPlan.new([ab_a1_1, ab_1, b, a, a_1])
      importer = DataImport::Runner.new(plan, mock_progress_class)

      call_order = []

      a.should_receive(:run) { call_order << :a }
      b.should_receive(:run) { call_order << :b }
      ab_1.should_receive(:run) { call_order << :ab_1 }
      a_1.should_receive(:run) { call_order << :a_1 }
      ab_a1_1.should_receive(:run) { call_order << :ab_a1_1}

      importer.run

      call_order.should == [:a, :b, :ab_1, :a_1, :ab_a1_1]
    end

    it 'handles dependencies correctly when :only is present' do
      a = DataImport::Definition.new 'A', :source, :target
      ab = DataImport::Definition.new 'AB', :source, :target
      ab.add_dependency('A')
      abc = DataImport::Definition.new 'ABC', :source, :target
      abc.add_dependency('AB')

      plan = DataImport::ExecutionPlan.new([abc, a, ab])
      importer = DataImport::Runner.new(plan, mock_progress_class)

      call_order = []

      a.should_receive(:run) { call_order << :a }
      ab.should_receive(:run) { call_order << :ab }
      abc.should_receive(:run) { call_order << :abc }

      importer.run :only => ['ABC']

      call_order.should == [:a, :ab, :abc]
    end

    it "raises an exception when the dependencies can't be resolved" do
      a = DataImport::Definition.new 'A', :source, :target
      b = DataImport::Definition.new 'B', :source, :target
      a.add_dependency('B')
      b.add_dependency('A')

      plan = DataImport::ExecutionPlan.new([a, b])
      importer = DataImport::Runner.new(plan, mock_progress_class)

      lambda do
        importer.run
      end.should raise_error(RuntimeError, "ciruclar dependencies: 'B' <-> 'A'")
    end

    it 'raises an error when invalid dependencies are found' do
      a = DataImport::Definition.new 'A', :source, :target
      a.add_dependency('NOT_PRESENT')

      plan = DataImport::ExecutionPlan.new([a])
      importer = DataImport::Runner.new(plan, mock_progress_class)

      lambda do
        importer.run
      end.should raise_error(RuntimeError, "no definition found for 'NOT_PRESENT'")
    end

    it 'can resolve dependencies which appear to be circular but are not' do
      a = DataImport::Definition.new 'A', :source, :target
      ab = DataImport::Definition.new 'AB', :source, :target
      ab.add_dependency('A')
      aba = DataImport::Definition.new 'AB-A', :source, :target
      aba.add_dependency('AB')
      aba.add_dependency('A')

      plan = DataImport::ExecutionPlan.new([a, aba, ab])
      importer = DataImport::Runner.new(plan, mock_progress_class)

      call_order = []

      a.should_receive(:run) { call_order << :a }
      ab.should_receive(:run) { call_order << :ab }
      aba.should_receive(:run) { call_order << :aba }

      importer.run

      call_order.should == [:a, :ab, :aba]
    end
  end

end
