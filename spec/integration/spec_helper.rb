require 'rubygems'
require 'bundler/setup'

require 'data-import'

require_relative '../acceptance/support/macros'

RSpec.configure do |config|
  config.extend TestingMacros
end
