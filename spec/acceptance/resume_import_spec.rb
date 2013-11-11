require 'acceptance/spec_helper'

describe 'resume import' do

  in_memory_mapping do
    FileUtils.rm '.Drivers', :force => true
    FileUtils.rm '.Cars', :force => true

    import 'Drivers' do
      from 'DriverData'
      to 'drivers'

      lookup_for :id, :column => :ID

      mapping :ID => :id
    end

    import 'Cars' do
      dependencies 'Drivers'

      from 'CarData'
      to 'cars'

      reference 'Drivers', :DriverID => :driver_id

      mapping :ID => :id
    end
  end

  database_setup do
    source.create_table :CarData do
      primary_key :ID
      Integer :DriverID
    end
    source.create_table :DriverData do
      primary_key :ID
    end

    target.create_table :cars do
      primary_key :id
      Integer :driver_id
    end
    target.create_table :drivers do
      primary_key :id
    end

    source[:DriverData].insert(:ID => 1)
    source[:CarData].insert(:ID => 1, :DriverID => 1)
  end

  it 'resumes the import where it stopped the last time' do
    DataImport.run_plan!(plan, :only => ['Drivers'])

    DataImport.run_plan!(plan, :only => ['Cars'], :partial => true)

    target_database[:drivers].count.should == 1
    target_database[:cars].to_a.should == [{:id => 1, :driver_id => 1}]
  end
end
