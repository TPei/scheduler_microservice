# frozen_string_literal: true

require 'app/middleware/sidekiq_logger'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://redis:6379' }

  config.server_middleware do |chain|
    chain.add Middleware::SidekiqLogger
  end
end
