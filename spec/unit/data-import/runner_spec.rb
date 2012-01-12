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
    let(:articles) { DataImport::Definition.new('Articles', 'tblNewsMessage', 'articles') }
    let(:plan) { DataImport::ExecutionPlan.new }
    before do
      plan.add_definition(articles)
      plan.add_definition(people)
    end

    subject { DataImport::Runner.new(plan, mock_progress_class) }

    it 'runs a set of definitions' do
      articles.should_receive(:setup).ordered
      articles.should_receive(:run).ordered
      articles.should_receive(:teardown).ordered
      people.should_receive(:setup).ordered
      people.should_receive(:run).ordered
      people.should_receive(:teardown).ordered

      subject.run
    end

    it ":only limits the definitions, which will be run" do
      articles.should_receive(:setup)
      articles.should_receive(:run)
      articles.should_receive(:teardown)

      subject.run :only => ['Articles']
    end
  end
end
