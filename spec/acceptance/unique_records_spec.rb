# -*- coding: utf-8 -*-
require 'acceptance/spec_helper'
require 'data-import'

describe 'insert unique records' do
  in_memory_mapping do
    import 'Cities' do
      from 'tblCities', :primary_key => 'sID'
      to 'cities', :mode => [:unique, :columns => [:name, :zip]]

      mapping 'strName' => 'name'
      mapping 'sZip' => 'zip'
      mapping 'strShort' => 'short_name'
    end
  end

  database_setup do
    source.create_table :tblCities do
      primary_key :sID
      String :strName
      Integer :sZip
      String :strShort
    end

    target.create_table :cities do
      primary_key :id
      String :name
      Integer :zip
      String :short_name
    end

    source[:tblCities].insert(:sID => 1, :strName => 'Bern', :sZip => 3012, :strShort => 'BE')
    source[:tblCities].insert(:sID => 2, :strName => 'Zürich', :sZip => 8051, :strShort => 'ZU')
    source[:tblCities].insert(:sID => 3, :strName => 'Bern', :sZip => 3012, :strShort => 'Bern')
  end

  it 'skips doubly defined records' do
    DataImport.run_plan!(plan)
    target_database[:cities].to_a.should == [{:id => 1, :name => 'Bern', :zip => 3012, :short_name => 'BE'},
                                             {:id => 2, :name => 'Zürich', :zip => 8051, :short_name => 'ZU'}]
  end
end
