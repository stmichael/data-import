require 'unit/spec_helper'

describe DataImport::FullMigration do

  let(:mock_progress_class) do
    Class.new do
      def initialize(name, total_steps); end

      def finish; end
    end
  end

  let(:mock_settings_store) do
    Class.new do
      def save(data)
      end
    end
  end

  context 'with simple definitions' do
    let(:people) { DataImport::Definition.new('People', 'tblPerson', 'people', nil) }
    let(:animals) { DataImport::Definition.new('Animals', 'tblAnimal', 'animals', nil) }
    let(:articles) { DataImport::Definition.new('Articles', 'tblNewsMessage', 'articles', nil) }
    let(:plan) { DataImport::ExecutionPlan.new }

    before do
      plan.add_definition(articles)
      plan.add_definition(people)
      plan.add_definition(animals)
    end

    it 'runs a set of definitions' do
      subject = described_class.new(plan, {}, mock_progress_class, mock_settings_store)

      articles.should_receive(:run)
      people.should_receive(:run)
      animals.should_receive(:run)

      subject.run
    end

    it ":only limits the definitions, which will be run" do
      subject = described_class.new(plan, {:only => ['People', 'Articles']}, mock_progress_class, mock_settings_store)

      people.should_receive(:run)
      articles.should_receive(:run)

      subject.run
    end
  end
end
