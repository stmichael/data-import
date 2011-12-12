
require 'yaml'
require 'progress'
require 'active_support/all'

require "data-import/version"
require 'data-import/runner'
require 'data-import/dsl'
require 'data-import/database'
require 'data-import/definition'
require 'data-import/importer'

# Monkeypatch for active support (see https://github.com/rails/rails/pull/2801)
class Time
  class << self
    def ===(other)
      super || (self == Time && other.is_a?(ActiveSupport::TimeWithZone))
    end
  end
end

module DataImport

  def self.run_config!(config_path, options = {})
    configuration = DataImport::Dsl.evaluate_import_config(config_path)
    run_definitions!(configuration.definitions, options)
  end

  def self.run_definitions!(definitions, options = {})
    runner = Runner.new(definitions)
    runner.run(options)
  end

end
