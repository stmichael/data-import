require 'data-import'

describe "simple mappings" do

  let(:dsl) do
    DataImport::Dsl.define do
      source :sequel, 'sqlite:/'
      target :sequel, 'sqlite:/'

      source_database.db.create_table :tblAnimal do
        primary_key :sAnimalID
        String :strAnimalTitleText
        Integer :sAnimalAge
        Integer :sDangerRating
        String :strThreat
      end

      target_database.db.create_table :animals do
        primary_key :id
        String :name
        Integer :age
        Integer :danger_rating
      end

      import 'Animals' do
        from 'tblAnimal', :primary_key => 'sAnimalID'
        to 'animals'

        mapping 'sAnimalID' => 'id'
        mapping 'strAnimalTitleText' => 'name'
        mapping 'sAnimalAge' => 'age'
        mapping 'strThreat' do |context, threat|
          rating = ['none', 'medium', 'big'].index(threat) + 1
          {:danger_rating => rating}
        end
      end
    end
  end

  let(:source) { dsl.source_database.db[:tblAnimal] }
  let(:target) { dsl.target_database.db[:animals] }

  before do
    source.insert(:sAnimalID => 1,
                  :strAnimalTitleText => 'Tiger',
                  :sAnimalAge => 23,
                  :strThreat => 'big')

    source.insert(:sAnimalID => 1293,
                  :strAnimalTitleText => 'Horse',
                  :sAnimalAge => 11,
                  :strThreat => 'medium')

    source.insert(:sAnimalID => 99,
                  :strAnimalTitleText => 'Cat',
                  :sAnimalAge => 5,
                  :strThreat => 'none')
  end


  it 'mapps columns to the new schema' do
    DataImport.run_definitions!(dsl.definitions)
    target.to_a.should == [{:id => 1, :name => "Tiger", :age => 23, :danger_rating => 3},
                           {:id => 99, :name => "Cat", :age => 5, :danger_rating => 1},
                           {:id => 1293, :name => "Horse", :age => 11, :danger_rating => 2}]
  end

end
