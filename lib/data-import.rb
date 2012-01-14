require 'yaml'
require 'progressbar'
require 'active_support/all'

require "data-import/version"
require "data-import/errors"
require 'data-import/dependency_resolver'
require 'data-import/runner'
require 'data-import/execution_plan'
require 'data-import/dsl'
require 'data-import/sequel/dataset'
require 'data-import/sequel/table'
require 'data-import/database'
require 'data-import/definition'
require 'data-import/importer'

module DataImport
  def self.run_config!(config_path, options = {})
    plan = DataImport::Dsl.evaluate_import_config(config_path)
    run_plan!(plan, options)
  end

  def self.run_plan!(plan, options = {})
    runner = Runner.new(plan)
    runner.run(options)
  end
end
