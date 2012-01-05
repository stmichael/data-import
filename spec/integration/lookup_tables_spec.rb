require 'data-import'

describe "lookup tables" do

  let(:plan) do
    DataImport::Dsl.define do
      source :sequel, 'sqlite:/'
      target :sequel, 'sqlite:/'

      source_database.db.create_table :tblArticles do
        primary_key :sArticleId
        String :strRef
      end

      source_database.db.create_table :tblPosts do
        primary_key :sPostId
        String :strArticleRef
      end

      target_database.db.create_table :articles do
        primary_key :id
        String :slug
      end

      target_database.db.create_table :posts do
        primary_key :id
        Integer :article_id
      end

      import 'Articles' do
        from 'tblArticles', :primary_key => 'sArticleId'
        to 'articles'

        lookup_for 'strRef'

        mapping 'strRef' => 'slug'
      end

      import 'Posts' do
        from 'tblPosts', :primary_key => 'sPostId'
        to 'posts'
        dependencies 'Articles'

        mapping 'sPostId' => :id
        mapping 'strArticleRef' do |context, value|
          { :article_id => context.definition('Articles').identify_by(:strRef, value) }
        end
      end
    end
  end

  let(:source_articles) { plan.definitions.first.source_database.db[:tblArticles] }
  let(:source_posts) { plan.definitions.first.source_database.db[:tblPosts] }

  let(:target_posts) { plan.definitions.first.target_database.db[:posts] }

  before do
    source_articles.insert(:sArticleId => 1,
                           :strRef => 'data-import-is-awesome')
    source_articles.insert(:sArticleId => 2,
                           :strRef => 'ruby-is-awesome')
    source_posts.insert(:sPostId => 7,
                        :strArticleRef => 'ruby-is-awesome')
    source_posts.insert(:sPostId => 8,
                        :strArticleRef => 'data-import-is-awesome')
    source_posts.insert(:sPostId => 9,
                        :strArticleRef => 'ruby-is-awesome')

  end


  it 'mapps columns to the new schema' do
    DataImport.run_plan!(plan)
    target_posts.to_a.should == [{:id => 7, :article_id => 2},
                                 {:id => 8, :article_id => 1},
                                 {:id => 9, :article_id => 2}]
  end

end
