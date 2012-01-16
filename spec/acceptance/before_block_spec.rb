require 'acceptance/spec_helper'

describe "before filter" do

  in_memory_mapping do
    before_filter do |row|
      row.each do |k, v|
        row[k] = v.downcase if v.respond_to?(:downcase)
      end
    end

    import 'Users' do
      from 'tblUser', :primary_key => 'sUserID'
      to 'users'

      mapping 'sUserID' => 'id'
      mapping 'strEmail' => 'email'
      mapping 'strUsername' => 'username'
    end
  end

  database_setup do
    source.create_table :tblUser do
      primary_key :sUserID
      String :strEmail
      String :strUsername
    end

    target.create_table :users do
      primary_key :id
      String :email
      String :username
    end

    source[:tblUser].insert(:sUserID => 1,
                            :strEmail => 'JANE.MEIERS@GMX.NET',
                            :strUsername => 'JANEMRS')
    source[:tblUser].insert(:sUserID => 2,
                            :strEmail => 'JOHN.DOE@GMAIL.COM',
                            :strUsername => 'JOHN_DOE')
  end

  it 'mapps columns to the new schema' do
    DataImport.run_plan!(plan)
    target_database[:users].to_a.should == [{:id => 1, :email => "jane.meiers@gmx.net", :username => 'janemrs'},
                                            {:id => 2, :email => "john.doe@gmail.com", :username => 'john_doe'}]
  end

end
