require 'acceptance/spec_helper'

describe "simple mappings" do

  in_memory_mapping do
    import 'Items' do
      from do |db|
        db[:tblItems].join(:tblOrderItems, :sItemID => :sID).group_and_count(:sID, :strProductTitle)
      end
      to 'items'

      mapping 'sID' => :id
      mapping 'strProductTitle' => :title
      mapping 'count' => :ordered_count
    end
  end

  database_setup do
    source.create_table :tblItems do
      primary_key :sID
      String :strProductTitle
    end

    source.create_table :tblOrderItems do
      Integer :sItemID
      Integer :sOrderID
    end

    target.create_table :items do
      primary_key :id
      String :title
      Integer :ordered_count
    end

    source[:tblItems].insert(:sID => 4, :strProductTitle => 'Lego')
    source[:tblItems].insert(:sID => 5, :strProductTitle => 'Computer')
    source[:tblItems].insert(:sID => 6, :strProductTitle => 'Car')


    source[:tblOrderItems].insert(:sItemID => 4, :sOrderID => 1)
    source[:tblOrderItems].insert(:sItemID => 4, :sOrderID => 2)
    source[:tblOrderItems].insert(:sItemID => 6, :sOrderID => 1)
    source[:tblOrderItems].insert(:sItemID => 5, :sOrderID => 3)
    source[:tblOrderItems].insert(:sItemID => 4, :sOrderID => 3)
    source[:tblOrderItems].insert(:sItemID => 6, :sOrderID => 3)
  end

  it 'uses the custom dataset for the migration' do
    DataImport.run_plan!(plan)
    target_database[:items].to_a.should == [{:id => 4, :title => 'Lego', :ordered_count => 3},
                                            {:id => 5, :title => 'Computer', :ordered_count => 1},
                                            {:id => 6, :title => 'Car', :ordered_count => 2}]
  end
end
