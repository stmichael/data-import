require 'unit/spec_helper'

describe DataImport::Sequel::NullReader do
  subject { described_class.new }

  describe '#each_row' do
    it 'returns without yielding anything' do
      subject.each_row do |row|
        raise "yielded anyway"
      end
    end
  end

  it '#count returns 0' do
    subject.count.should == 0
  end
end
