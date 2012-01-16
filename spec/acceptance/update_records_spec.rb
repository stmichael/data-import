require 'data-import'

describe "update existing records" do

  in_memory_mapping do
    import 'Article Authors' do
      from 'tblArticleAbout', :primary_key => 'sID'
      to 'articles', :mode => :update

      mapping 'lArticleId' => 'id'
      mapping 'strWho' => 'author'
    end
  end

  database_setup do
    source.create_table :tblArticleAbout do
      primary_key :sID
      Integer :lArticleId
      String :strWho
    end

    target.create_table :articles do
      primary_key :id
      String :title
      String :author
    end

    source[:tblArticleAbout].insert(:sID => 1,
                                    :lArticleId => 12,
                                    :strWho => 'Adam K.')
    source[:tblArticleAbout].insert(:sID => 2,
                                    :lArticleId => 145,
                                    :strWho => 'James G.')

    target[:articles].insert(:id => 12,
                             :title => 'The Book!')
    target[:articles].insert(:id => 145,
                             :title => 'The other Book.')

  end

  it 'mapps columns to the new schema' do
    DataImport.run_plan!(plan)
    target_database[:articles].to_a.should == [{:id => 12, :title => "The Book!", :author => 'Adam K.'},
                                               {:id => 145, :title => "The other Book.", :author => 'James G.'}]
  end

end
