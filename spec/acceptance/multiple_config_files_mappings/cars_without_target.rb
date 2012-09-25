source 'sqlite:/'

import 'cars' do
  dependencies 'manufacturers'

  from 'tblCar'
  to 'cars'

  reference 'manufacturers', :sManufId => :manufacturer_id
  mapping :strName => :name
end
