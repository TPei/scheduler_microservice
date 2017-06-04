# frozen_string_literal: true

require 'app/middleware/sidekiq_logger'

Sidekiq.configure_server do |config|
  if ENV['REDIS_URL']
    config.redis = { url: ENV['REDIS_URL' }
  end

  config.server_middleware do |chain|
    chain.add Middleware::SidekiqLogger
  end
end
