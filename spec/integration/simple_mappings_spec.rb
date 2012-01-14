require 'integration/spec_helper'

describe "simple mappings" do

  in_memory_mapping do
    import 'Animals' do
      from 'tblAnimal', :primary_key => 'sAnimalID'
      to 'animals'

      mapping 'sAnimalID' => :id
      mapping 'strAnimalTitleText' => :name
      mapping 'sAnimalAge' => 'age'
      mapping 'strThreat' do |context, threat|
        rating = ['none', 'medium', 'high'].index(threat) + 1
        {:danger_rating => rating}
      end
      mapping 'strAnimalTitleText', 'sAnimalAge' do |context, title, age|
        {:formatted_name_cache => "%s (%d)" % [title, age]}
      end

      after_row do |context, old_row, mapped_row|
        if old_row[:dteBorn].present?
          event = '%s was born' % mapped_row[:name]
          target_database.insert_row(:animal_logs, {:occured_at => old_row[:dteBorn], :event => event})
        end

        if old_row[:dteDied].present?
          event = '%s died' % mapped_row[:name]
          target_database.insert_row(:animal_logs, {:occured_at => old_row[:dteDied], :event => event})
        end
      end

      after do
        target_database.insert_row(:danger_ratings, {:id => 1, :description => 'none'})
        target_database.insert_row(:danger_ratings, {:id => 2, :description => 'medium'})
        target_database.insert_row(:danger_ratings, {:id => 3, :description => 'high'})
      end
    end
  end

  database_setup do
    source.create_table :tblAnimal do
      primary_key :sAnimalID
      String :strAnimalTitleText
      Integer :sAnimalAge
      Integer :sDangerRating
      String :strThreat
      Date :dteBorn
      Date :dteDied
    end

    target.create_table :animals do
      primary_key :id
      String :name
      Integer :age
      Integer :danger_rating
      String :formatted_name_cache
    end

    target.create_table :animal_logs do
      primary_key :id
      Date :occured_at
      String :event
    end

    target.create_table :danger_ratings do
      primary_key :id
      String :description
    end


    source[:tblAnimal].insert(:sAnimalID => 1,
                              :strAnimalTitleText => 'Tiger',
                              :sAnimalAge => 23,
                              :strThreat => 'high',
                              :dteBorn => Date.new(2000, 6, 1))

    source[:tblAnimal].insert(:sAnimalID => 1293,
                              :strAnimalTitleText => 'Horse',
                              :sAnimalAge => 11,
                              :strThreat => 'medium',
                              :dteBorn => Date.new(2000, 12, 21),
                              :dteDied => Date.new(2011, 04, 26))

    source[:tblAnimal].insert(:sAnimalID => 99,
                              :strAnimalTitleText => 'Cat',
                              :sAnimalAge => 5,
                              :strThreat => 'none',
                              :dteBorn => Date.new(1998, 11, 9))
  end

  it 'mapps columns to the new schema' do
    DataImport.run_plan!(plan)
    target_database[:animals].to_a.should == [{:id => 1, :name => "Tiger", :age => 23, :danger_rating => 3, :formatted_name_cache => 'Tiger (23)'},
                                              {:id => 99, :name => "Cat", :age => 5, :danger_rating => 1, :formatted_name_cache => 'Cat (5)'},
                                              {:id => 1293, :name => "Horse", :age => 11, :danger_rating => 2, :formatted_name_cache => 'Horse (11)'}]
  end

  it 'runs after blocks after the rows were imported' do
    DataImport.run_plan!(plan)
    target_database[:danger_ratings].to_a.should == [{:id => 1, :description => 'none'},
                                                     {:id => 2, :description => 'medium'},
                                                     {:id => 3, :description => 'high'}]
  end

  it 'runs after_row blocks after every row' do
    DataImport.run_plan!(plan)
    target_database[:animal_logs].map do |log|
      log.delete(:id)
      log
    end.to_a.should == [{:occured_at => Date.new(2000, 6, 1), :event => "Tiger was born"},
                        {:occured_at => Date.new(1998, 11, 9), :event => "Cat was born"},
                        {:occured_at => Date.new(2000, 12, 21), :event => "Horse was born"},
                        {:occured_at => Date.new(2011, 4, 26), :event => "Horse died"}]

  end
end
