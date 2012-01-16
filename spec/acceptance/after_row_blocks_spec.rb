require 'acceptance/spec_helper'

describe 'execute code after each row' do

  in_memory_mapping do
    import 'Sales Leads' do
      from 'SL_NewLeads', :primary_key => 'slNewLeadsID'
      to 'sales_leads'

      mapping 'slNewLeadsID' => :id

      after_row do |context, old_row, new_row|
        target_database.db[:contacts].insert(:firstname => old_row[:slName1],
                                             :lastname => old_row[:slName2])
      end
    end
  end

  database_setup do
    source.create_table :SL_NewLeads do
      primary_key :slNewLeadsID
      String :slName1
      String :slName2
    end

    target.create_table :sales_leads do
      primary_key :id
    end

    target.create_table :contacts do
      primary_key :id
      String :firstname
      String :lastname
    end

    source[:SL_NewLeads].insert('slNewLeadsID' => 11,
                                'slName1' => 'Peter',
                                'slName2' => 'Wood')
    source[:SL_NewLeads].insert('slNewLeadsID' => 32,
                                'slName1' => 'Jane',
                                'slName2' => 'Doe')
  end

  it 'should execute the after row blocks' do
    DataImport.run_plan!(plan)
    target_database[:contacts].to_a.should == [{:id => 1, :firstname => "Peter", :lastname => "Wood"},
                                               {:id => 2, :firstname => "Jane", :lastname => "Doe"}]
  end

end
