require 'yaml'
require 'progressbar'
require 'ostruct'
require 'active_support/all'

require "data-import/version"
require "data-import/errors"
require 'data-import/dependency_resolver'
require 'data-import/execution_context'
require 'data-import/runner'
require 'data-import/execution_plan'
require 'data-import/dsl'
require 'data-import/sequel/dataset'
require 'data-import/sequel/table'
require 'data-import/sequel/writer'
require 'data-import/sequel/postgres/update_sequence'
require 'data-import/database'
require 'data-import/definition'
require 'data-import/logger'

module DataImport
  class << self
    def run_config!(config_paths, options = {})
      plan = DataImport::Dsl.evaluate_import_config(config_paths, options)
      run_plan!(plan, options)
    end

    def run_plan!(plan, options = {})
      runner = Runner.new(plan)
      runner.run(options)
    end

    def logger
      @logger ||= Logger.new(full_logger, important_logger)
    end

    def full_logger
      @full_logger || ::Logger.new(File.new('import.log', 'w'))
    end

    def full_logger=(logger)
      @logger = nil
      @full_logger = logger
    end

    def important_logger
      @important_logger || ::Logger.new($stdout)
    end

    def important_logger=(logger)
      @logger = nil
      @important_logger = logger
    end
  end
end
