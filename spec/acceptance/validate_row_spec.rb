require 'acceptance/spec_helper'

describe 'validate rows before insertion' do

  in_memory_mapping do
    import 'People' do
      from 'Person'
      to 'females'

      mapping 'Name' => :name
      mapping 'Gender' => :gender

      validate_row do |context, row|
        row[:gender] == 'f'
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
    end

    source[:Person].insert('Name' => 'Tina', 'Gender' => 'f')
    source[:Person].insert('Name' => 'Jack', 'Gender' => 'm')
  end

  it 'skip invalid records' do
    DataImport.run_plan!(plan)
    target_database[:females].to_a.should == [{:name => 'Tina', :gender => 'f'}]
  end

end
