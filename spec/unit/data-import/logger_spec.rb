require 'unit/spec_helper'

describe DataImport::Logger do
  let(:important) { mock }
  let(:full) { mock }
  subject { described_class.new(full, important) }

  it 'writes debug and info messages only to the full logger' do
    full.should_receive(:debug).with('debug message')
    full.should_receive(:info).with('info message')

    subject.debug 'debug message'
    subject.info 'info message'
  end

  it 'writes warn, error and fatal messages to both loggers' do
    full.should_receive(:warn).with('warn message')
    full.should_receive(:error).with('error message')
    full.should_receive(:fatal).with('fatal message')
    important.should_receive(:warn).with('warn message')
    important.should_receive(:error).with('error message')
    important.should_receive(:fatal).with('fatal message')

    subject.warn 'warn message'
    subject.error 'error message'
    subject.fatal 'fatal message'
  end
end
