require 'rubygems'
require 'bundler/setup'

require 'data-import'

require_relative 'support/macros'

RSpec.configure do |config|
  config.extend TestingMacros
end
