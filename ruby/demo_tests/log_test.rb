require 'logger'

logger = Logger.new(STDOUT)
logger.debug "Created logger"
logger.debug("Created logger")
logger.info("Program started")
logger.warn("Nothing to do!")
logger.error("error log")
logger.info('initialize') { "Initializing..." }
