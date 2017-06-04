# frozen_string_literal: true

require 'sidekiq'

Sidekiq.configure_client do |config|
  if ENV['REDIS_SENTINEL_SERVICE']
    config.redis = {
      url: 'redis://mymaster',
      sentinels: [{ host: ENV['REDIS_SENTINEL_SERVICE'], port: '26379' }]
    }
  end
end
