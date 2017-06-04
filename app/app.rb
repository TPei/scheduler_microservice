# frozen_string_literal: true

require 'active_support/deprecation'
require 'active_support/all'

set :environment, :production # TODO
Bundler.require(Sinatra::Base.environment)

def my_logger
  @my_logger ||= Logger.new $stdout
end

def logger
  my_logger
end

module Api
  def self.env
    ENV['RACK_ENV'] || 'development'
  end

  Sinatra::Base.set :environment, env

  logger.info('Sinatra Container started')

  require 'app/v1/api.rb'
end

module Sinatra
  class Base
    def logger
      my_logger
    end
  end
end
