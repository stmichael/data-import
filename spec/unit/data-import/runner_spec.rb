require 'unit/spec_helper'

describe DataImport::Runner do
  let(:plan) { stub }
  subject { described_class.new(plan) }

  context 'complete import' do
    it 'executes the plan with the full migration strategy' do
      strategy = stub
      DataImport::FullMigration.should_receive(:new).with(plan, {}).and_return(strategy)
      strategy.should_receive(:run)

      subject.run
    end
  end

  context 'partial import' do
    it 'executes the plan with the partial migration strategy' do
      strategy = stub
      DataImport::PartialMigration.should_receive(:new).with(plan, :partial => true).and_return(strategy)
      strategy.should_receive(:run)

      subject.run :partial => true
    end
  end
end
