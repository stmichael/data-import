require 'acceptance/spec_helper'

describe 'definition dependencies' do

  in_memory_mapping do
    import 'Drivers' do
      from 'DriverData', :primary_key => 'ID'
      to 'drivers'

      mapping 'ID' => :id
    end

    import 'Cars' do
      from 'CarData', :primary_key => 'ID'
      to 'cars'
      dependencies 'Drivers', 'Colors'

      mapping 'ID' => :id
    end

    import 'Colors' do
      from 'Colors', :primary_key => 'ID'
      to 'colors'

      mapping 'ID' => :id
    end

    import 'Wheels' do
      from 'WheelData', :primary_key => 'ID'
      to 'wheels'
      dependencies 'Cars'

      mapping 'ID' => :id
    end
  end

  database_setup do
    [:DriverData, :CarData, :Colors, :WheelData].each do |table_name|
      source.create_table table_name do
        primary_key :ID
      end

      source[table_name].insert(:ID => 1)
    end

    [:drivers, :cars, :colors, :wheels].each do |table_name|
      target.create_table table_name do
        primary_key :ID
      end
    end
  end

  it 'lets you import a subset of only' do
    DataImport.run_plan!(plan, :only => ['Colors', 'Drivers'])

    target_database[:colors].count.should == 1
    target_database[:drivers].count.should == 1

    target_database[:cars].count.should == 0
    target_database[:wheels].count.should == 0
  end

  it 'resolves dependencies' do
    DataImport.run_plan!(plan, :only => ['Wheels'])

    target_database[:colors].count.should == 1
    target_database[:drivers].count.should == 1
    target_database[:cars].count.should == 1
    target_database[:wheels].count.should == 1
  end

  describe "circular dependencies" do
    in_memory_mapping do
      import 'Cats' do
        dependencies 'Cats'
      end

      import 'People' do
        dependencies 'Cats'
      end
    end

    it 'recognizes circular dependencies' do
      lambda do
        DataImport.run_plan!(plan)
      end.should raise_error(DataImport::CircularDependencyError)
    end
  end

  describe "missing dependencies" do
    in_memory_mapping do
      import 'Dogs' do
        dependencies 'Non-Existing-Owners'
      end
    end

    it 'recognizes missing dependencies' do
      lambda do
        DataImport.run_plan!(plan)
      end.should raise_error(DataImport::MissingDefinitionError)
    end
  end

  describe "unloaded dependencies" do
    in_memory_mapping do
      import 'Cats' do
        from 'LegacyCats', :primary_key => 'ID'
        to 'cats'

        mapping 'sOwnerID' do |context, value|
          context.definition('Owners')
          {}
        end
      end

      import 'Owners' do
      end
    end

    database_setup do
      source.create_table :LegacyCats do
        primary_key :ID
        Integer :sOwnerID
      end
      target.create_table :cats do
        primary_key :id
      end

      source[:LegacyCats].insert(:ID => 1, :sOwnerID => 1)
    end

    it 'recognizes unloaded dependencies' do
      lambda do
        DataImport.run_plan!(plan, :only => ['Cats'])
      end.should raise_error(DataImport::MissingDefinitionError)
    end
  end
end
