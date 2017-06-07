# frozen_string_literal: true

logger = Logger.new $stdout

Dir[File.expand_path('../../../app/workers/*.rb', __FILE__)].each do |file|
  require file
end

logger.info('Sidekiq Container started')
