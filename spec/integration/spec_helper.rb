require 'rubygems'
require 'bundler/setup'

require 'data-import'

require File.join(File.dirname(__FILE__), '../acceptance/support/macros')

RSpec.configure do |config|
  config.extend TestingMacros
end
