#\ -s puma
require_relative './config/setup_web'
require 'app/app'
run Rack::URLMap.new('/v1' => Api::ApiV1)
