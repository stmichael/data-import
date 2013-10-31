require 'acceptance/spec_helper'

describe 'logger' do

  in_memory_mapping do
    import 'People' do
      from 'Person'
      to 'females'

      mapping 'Name' => :name
      mapping 'Gender' => :gender

      validate_row do
        if mapped_row[:gender] == 'f'
          true
        else
          logger.info "Row #{row} skipped since the gender is male"
          false
        end
      end
    end
  end

  database_setup do
    source.create_table :Person do
      String :Name
      String :Gender
    end

    target.create_table :females do
      String :name
      String :gender
    end

    source[:Person].insert('Name' => 'Tina', 'Gender' => 'f')
    source[:Person].insert('Name' => 'Jack', 'Gender' => 'm')
  end

  let(:messages) { StringIO.new }

  it 'skip invalid records' do
    logger = Logger.new(messages)
    logger.formatter = proc { |severity, time, progname, msg| "%s: %s\n" % [severity, msg] }

    DataImport.full_logger = logger

    DataImport.run_plan!(plan)

    messages.string.strip.should == "INFO: Starting to import \"People\"\nINFO: Row {:Name=>\"Jack\", :Gender=>\"m\"} skipped since the gender is male"
  end

end
