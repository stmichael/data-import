require 'acceptance/spec_helper'

describe "import without source" do

  in_memory_mapping do
    import 'Static objects' do
      to 'objects'

      after do
        target_database[:objects].insert(:name => 'a box')
        target_database[:objects].insert(:name => 'my cat')
      end
    end
  end

  database_setup do
    target.create_table :objects do
      primary_key :id
      String :name
    end
  end

  it 'inserts static objects into the target table' do
    DataImport.run_plan!(plan)
    target_database[:objects].to_a.should == [{:id => 1, :name => 'a box'},
                                              {:id => 2, :name => 'my cat'}]
  end

end
