require 'data-import'

describe "before filter" do

  let(:plan) do
    DataImport::Dsl.define do
      source :sequel, 'sqlite:/'
      target :sequel, 'sqlite:/'

      before_filter do |row|
        row.each do |k, v|
          row[k] = v.downcase if v.respond_to?(:downcase)
        end
      end

      source_database.db.create_table :tblUser do
        primary_key :sUserID
        String :strEmail
        String :strUsername
      end

      target_database.db.create_table :users do
        primary_key :id
        String :email
        String :username
      end

      import 'Users' do
        from 'tblUser', :primary_key => 'sUserID'
        to 'users'

        mapping 'sUserID' => 'id'
        mapping 'strEmail' => 'email'
        mapping 'strUsername' => 'username'
      end
    end
  end

  let(:source) { plan.definitions.first.source_database.db[:tblUser] }
  let(:target) { plan.definitions.first.target_database.db[:users] }

  before do
    source.insert(:sUserID => 1,
                  :strEmail => 'JANE.MEIERS@GMX.NET',
                  :strUsername => 'JANEMRS')

    source.insert(:sUserID => 2,
                  :strEmail => 'JOHN.DOE@GMAIL.COM',
                  :strUsername => 'JOHN_DOE')
  end


  it 'mapps columns to the new schema' do
    DataImport.run_plan!(plan)
    target.to_a.should == [{:id => 1, :email => "jane.meiers@gmx.net", :username => 'janemrs'},
                           {:id => 2, :email => "john.doe@gmail.com", :username => 'john_doe'}]
  end

end
