require 'acceptance/spec_helper'

describe 'seed data' do

  in_memory_mapping do
    import 'Cargo' do
      from 'TB_CARGO'
      to 'cargo'

      mapping 'ID' => :id

      seed :type => 'imported', :source => 'TB_CARGO'
      seed :created_at => Date.new(2012, 01, 15)
    end
  end

  database_setup do
    source.create_table :TB_CARGO do
      primary_key :ID
    end

    target.create_table :cargo do
      primary_key :id
      String :type
      String :source
      Date :created_at
    end

    source[:TB_CARGO].insert('ID' => 34)
    source[:TB_CARGO].insert('ID' => 78)
    source[:TB_CARGO].insert('ID' => 92)
  end

  it 'should add the seeded columns' do
    DataImport.run_plan!(plan)
    target_database[:cargo].to_a.should == [{:id => 34, :type => 'imported', :source => 'TB_CARGO', :created_at => Date.new(2012, 01, 15)},
                                            {:id => 78, :type => 'imported', :source => 'TB_CARGO', :created_at => Date.new(2012, 01, 15)},
                                            {:id => 92, :type => 'imported', :source => 'TB_CARGO', :created_at => Date.new(2012, 01, 15)}]
  end
end
