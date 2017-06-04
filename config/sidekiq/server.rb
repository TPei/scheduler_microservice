# frozen_string_literal: true

require 'app/middleware/sidekiq_logger'

Sidekiq.configure_server do |config|
  if ENV['REDIS_SENTINEL_SERVICE']
    config.redis = {
      url: 'redis://mymaster',
      sentinels: [{ host: ENV['REDIS_SENTINEL_SERVICE'], port: '26379' }]
    }
  end

  config.server_middleware do |chain|
    chain.add Middleware::SidekiqLogger
  end
end
