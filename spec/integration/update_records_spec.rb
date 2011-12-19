require 'data-import'

describe "update existing records" do

  let(:plan) do
    DataImport::Dsl.define do
      source :sequel, 'sqlite:/'
      target :sequel, 'sqlite:/'

      source_database.db.create_table :tblArticleAbout do
        primary_key :sID
        Integer :lArticleId
        String :strWho
      end

      target_database.db.create_table :articles do
        primary_key :id
        String :title
        String :author
      end

      import 'Article Authors' do
        from 'tblArticleAbout', :primary_key => 'sID'
        to 'articles', :mode => :update

        mapping 'lArticleId' => 'id'
        mapping 'strWho' => 'author'
      end
    end
  end

  let(:source) { plan.definitions.first.source_database.db[:tblArticleAbout] }
  let(:target) { plan.definitions.first.target_database.db[:articles] }

  before do
    source.insert(:sID => 1,
                  :lArticleId => 12,
                  :strWho => 'Adam K.')
    source.insert(:sID => 2,
                  :lArticleId => 145,
                  :strWho => 'James G.')

    target.insert(:id => 12,
                  :title => 'The Book!')
    target.insert(:id => 145,
                  :title => 'The other Book.')

  end


  it 'mapps columns to the new schema' do
    DataImport.run_plan!(plan)
    target.to_a.should == [{:id => 12, :title => "The Book!", :author => 'Adam K.'},
                           {:id => 145, :title => "The other Book.", :author => 'James G.'}]
  end

end
