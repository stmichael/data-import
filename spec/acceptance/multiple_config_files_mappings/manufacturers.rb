source 'sqlite:/'
target 'sqlite:/'

import 'manufacturers' do
  from 'tblManufacturer'
  to 'manufacturers'

  lookup_for :id, :column => 'sId'

  mapping :sId => :id
  mapping :strName => :name
end
