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
      end

      target_database.db.create_table :animals do
        primary_key :id
        String :name
        Integer :age
      end

      import 'Animals' do
        from 'tblAnimal', :primary_key => 'sAnimalID'
        to 'animals'

        mapping 'sAnimalID' => 'id'
        mapping 'strAnimalTitleText' => 'name'
        mapping 'sAnimalID' => 'age'
      end
    end
  end

  let(:source) { dsl.source_database.db[:tblAnimal] }
  let(:target) { dsl.target_database.db[:animals] }

  before do
    source.insert(:sAnimalID => 1,
                  :strAnimalTitleText => 'Tiger',
                  :sAnimalAge => 23)

    source.insert(:sAnimalID => 1293,
                  :strAnimalTitleText => 'Horse',
                  :sAnimalAge => 9)

    source.insert(:sAnimalID => 99,
                  :strAnimalTitleText => 'Cat',
                  :sAnimalAge => 12)
  end


  it 'mapps columns to the new schema' do
    DataImport.run_definitions!(dsl.definitions)
    target.to_a.should == [{:id=>1, :name=>"Tiger", :age=> 1},
                           {:id=>2, :name=>"Cat", :age=> 99},
                           {:id=>3, :name=>"Horse", :age=> 1293}]
  end

end
