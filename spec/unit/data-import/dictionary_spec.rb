require 'unit/spec_helper'

describe DataImport::Dictionary do
  subject { described_class.new }
  it 'fetches an id by its key' do
    subject.add('leo', 'lion')
    subject.lookup('leo').should == 'lion'
  end

  it 'has a hash representation of the data' do
    subject.add('chuck norris', 'strong')
    subject.to_hash.should == {'chuck norris' => 'strong'}
  end
end

describe DataImport::CaseIgnoringDictionary do
  subject { described_class.new }
  it 'fetches an id by its key ignoring case' do
    subject.add('leo', 'lion')
    subject.lookup('Leo').should == 'lion'
  end

  it 'handles nil values' do
    subject.add(nil, 0)
    subject.lookup(nil).should == 0
  end
end
