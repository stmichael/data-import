require 'unit/spec_helper'

describe DataImport::SettingsStore do
  it 'saves and loads the completed definitions' do
    subject.save(:completed_definitions => ['animals'])
    subject.load[:completed_definitions].should == ['animals']
  end

  it 'saves and loads the id mappings' do
    subject.save(:id_mappings => {:mappings => {4 => 7}})
    subject.load[:id_mappings].should == {:mappings => {4 => 7}}
  end

  context 'without settings' do
    before do
      File.delete(DataImport::SettingsStore::SETTINGS_FILE) if File.exist?(DataImport::SettingsStore::SETTINGS_FILE)
    end

    it 'loads an empty set' do
      subject.load.should == {}
    end
  end
end
