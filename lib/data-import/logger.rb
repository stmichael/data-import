module DataImport
  class Logger
    def initialize(full_logger, important_logger)
      @full_logger = full_logger
      @important_logger = important_logger
    end

    def debug(message = nil, &block)
      @full_logger.debug(message, &block)
    end

    def info(message = nil, &block)
      @full_logger.info(message, &block)
    end

    def warn(message = nil, &block)
      @full_logger.warn(message, &block)
      @important_logger.warn(message, &block)
    end

    def error(message = nil, &block)
      @full_logger.error(message, &block)
      @important_logger.error(message, &block)
    end

    def fatal(message = nil, &block)
      @full_logger.fatal(message, &block)
      @important_logger.fatal(message, &block)
    end
  end
end
