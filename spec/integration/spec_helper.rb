require 'rubygems'
require 'bundler/setup'

require 'data-import'

require File.join(File.dirname(__FILE__), '../acceptance/support/macros')

RSpec.configure do |config|
  config.extend TestingMacros
  config.filter_run_excluding :postgres => true unless ENV.has_key? 'ENABLE_POSTGRES_SPECS'
end
