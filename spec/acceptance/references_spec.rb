require 'acceptance/spec_helper'

describe "references on tables" do

  in_memory_mapping do
    import 'address' do
      from 'Address'
      to 'addresses'

      lookup_for :id, :column => 'OID'
      lookup_for :zip_code, :column => 'Zip'

      mapping 'OID' => :id
      mapping 'CityName' => :city
    end

    import 'person' do
      dependencies 'address'

      from 'Person'
      to 'people'

      reference 'address', 'AddressOID' => :address_id
    end

    import 'house' do
      dependencies 'address'

      from 'House'
      to 'houses'

      reference 'address', 'Zip' => :address_id, :lookup => :zip_code
    end
  end

  database_setup do
    source.create_table 'Address' do
      primary_key :OID
      String :CityName
      Integer :Zip
    end
    source.create_table 'Person' do
      Integer :AddressOID
    end
    source.create_table 'House' do
      Integer :Zip
    end

    target.create_table 'addresses' do
      primary_key :id
      String :city
    end
    target.create_table 'people' do
      Integer :address_id
    end
    target.create_table 'houses' do
      Integer :address_id
    end

    source[:Address].insert(:OID => 5, :CityName => 'Reykjavik', :Zip => 83744)
    source[:Person].insert(:AddressOID => 5)
    source[:House].insert(:Zip => 83744)
  end

  it 'maps to old address id to the new one' do
    DataImport.run_plan!(plan, :only => ['person'])
    address_id = target_database[:addresses].first[:id]
    target_database[:people].to_a.should == [{:address_id => address_id}]
  end

  it 'maps to old address id to the new one using the reference lookup' do
    DataImport.run_plan!(plan, :only => ['house'])
    address_id = target_database[:addresses].first[:id]
    target_database[:houses].to_a.should == [{:address_id => address_id}]
  end
end
