require 'spec_helper'

describe DataImport::Runner do

  context 'with simple definitions' do
    let(:people) { DataImport::Definition.new('People', 'tblPerson', 'people') }
    let(:animals) { DataImport::Definition.new('Animals', 'tblAnimal', 'animals') }
    let(:articles) { DataImport::Definition.new('Articles', 'tblNewsMessage', 'articles') }
    let(:definitions) { [articles, people, animals] }

    subject { DataImport::Runner.new(definitions) }

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

      importer = DataImport::Runner.new([ab_a1_1, ab_1, b, a, a_1])

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

      importer = DataImport::Runner.new([abc, a, ab])

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

      importer = DataImport::Runner.new([a, b])

      lambda do
        importer.run
      end.should raise_error(RuntimeError, "ciruclar dependencies: 'B' <-> 'A'")
    end

    it 'raises an error when invalid dependencies are found' do
      a = DataImport::Definition.new 'A', :source, :target
      a.add_dependency('NOT_PRESENT')

      importer = DataImport::Runner.new([a])

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

      importer = DataImport::Runner.new([a, aba, ab])

      call_order = []

      a.should_receive(:run) { call_order << :a }
      ab.should_receive(:run) { call_order << :ab }
      aba.should_receive(:run) { call_order << :aba }

      importer.run

      call_order.should == [:a, :ab, :aba]
    end
  end

end
