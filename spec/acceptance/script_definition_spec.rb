require 'acceptance/spec_helper'

describe "import with a script" do
  in_memory_mapping do
    import 'Animals' do
      from 'tblAnimal'
      to 'animals'

      seed :king => false

      mapping 'Name' => :name
    end

    script 'King of the Animals' do
      dependencies 'Animals'

      body do
        if source_database.db[:tblAnimal].filter(:name => 'Lion').empty?
          target_database.db[:animals].insert(:name => 'Lion', :king => true)
        end
        progress_reporter.inc 100
      end
    end
  end

  database_setup do
    source.create_table :tblAnimal do
      primary_key :sAnimalID
      String :Name
    end

    target.create_table :animals do
      primary_key :id
      String :name
      Boolean :king
    end

    source[:tblAnimal].insert(:Name => 'Monkey')
    source[:tblAnimal].insert(:Name => 'Scorpion')
    source[:tblAnimal].insert(:Name => 'Tiger')
  end

  it 'executes the script' do
    DataImport.run_plan!(plan)

    target_database[:animals].filter(:king => true).first[:name].should == 'Lion'
  end
end
