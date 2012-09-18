require 'acceptance/spec_helper'

describe 'multiple configuration files' do
  def setup_databases(car_source, car_target, manufacturer_source, manufacturer_target)
    manufacturer_source.create_table :tblManufacturer do
      Integer :sId
      String :strName
    end
    car_source.create_table :tblCar do
      Integer :sManufId
      String :strName
    end
    manufacturer_target.create_table :manufacturers do
      primary_key :id
      String :name
    end
    car_target.create_table :cars do
      Integer :manufacturer_id
      String :name
    end
  end

  context 'with valid mapping files' do
    let(:config_files) { [File.join(File.dirname(__FILE__), 'multiple_config_files_mappings', 'cars.rb'),
                          File.join(File.dirname(__FILE__), 'multiple_config_files_mappings', 'manufacturers.rb')] }

    it 'loads multiple config files' do
      plan = DataImport::Dsl.evaluate_import_config(config_files)
      car_source = plan.definition('cars').source_database
      car_target = plan.definition('cars').target_database
      manufacturer_source = plan.definition('manufacturers').source_database
      manufacturer_target = plan.definition('manufacturers').target_database

      setup_databases(car_source, car_target, manufacturer_source, manufacturer_target)

      manufacturer_source[:tblManufacturer].insert(:sId => 1, :strName => 'Ferrari')
      car_source[:tblCar].insert(:sManufId => 1, :strName => 'Testarossa')

      DataImport.run_plan!(plan)

      manufacturer_target[:manufacturers].to_a.should == [{:id => 1, :name => 'Ferrari'}]
      car_target[:cars].to_a.should == [{:manufacturer_id => 1, :name => 'Testarossa'}]
    end
  end

  context 'without a source database' do
    let(:config_files) { File.join(File.dirname(__FILE__), 'multiple_config_files_mappings', 'cars_without_source.rb') }

    it 'raises an exception' do
      lambda do
        DataImport::Dsl.evaluate_import_config(config_files)
      end.should raise_error(DataImport::MissingDatabaseError)
    end
  end

  context 'without a target database' do
    let(:config_files) { File.join(File.dirname(__FILE__), 'multiple_config_files_mappings', 'cars_without_target.rb') }

    it 'raises an exception' do
      lambda do
        DataImport::Dsl.evaluate_import_config(config_files)
      end.should raise_error(DataImport::MissingDatabaseError)
    end
  end
end
