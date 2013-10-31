require 'acceptance/spec_helper'

describe 'logger' do

  SEEDS = { :planet => 'Earth' }

  OPTIONS = { :name_mapping => :name, :map_gender? => false, :validate => false, :seeds => SEEDS }

  in_memory_mapping(OPTIONS) do
    import 'with options' do
      from 'Person'
      to 'females'

      mapping 'Name' => options[:name_mapping]
      
      mapping 'options in a block mapping' do
        if options[:map_gender?]
          { :gender => :gender }
        end
      end

      if options[:validate]
        validate_row do
          if mapped_row[:gender] == 'f'
            true
          else
            false
          end
        end
      end

      seed options[:seeds]
    end

    script 'Options test' do
      body do
        target_database.db[:females].insert(options[:seeds].merge(:name => 'Andy', :gender => 'm' ))
      end
    end
  end

  database_setup do
    source.create_table :Person do
      String :Name
      String :Gender
    end

    target.create_table :females do
      String :name
      String :gender
      String :planet
    end

    source[:Person].insert('Name' => 'Tina', 'Gender' => 'f')
    source[:Person].insert('Name' => 'Jack', 'Gender' => 'm')
  end

  it 'provides options to the DSL' do
    plan.options.should eq OPTIONS

    DataImport.run_plan!(plan)

    target_database[:females].count.should == 3
    target_database[:females].first[:gender].should be nil
    target_database[:females].first[:planet].should eq SEEDS[:planet]
    target_database[:females].first(:name => 'Andy')[:planet].should eq SEEDS[:planet]
  end

end
