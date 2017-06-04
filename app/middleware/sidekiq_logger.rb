# frozen_string_literal: true

require 'logger'

module Middleware
  class SidekiqLogger
    # rubocop:disable RescueException
    def call(worker, _msg, _queue)
      start = Time.now
      logger.info("#{worker.class}:start")
      yield
      logger.info("#{worker.class}:done:#{elapsed(start)}sec")
    rescue Exception
      logger.info("#{worker.class}:fail:#{elapsed(start)} sec")
      raise
    end
    # rubocop:enable all

    private

    def logger
      @logger ||= Logger.new $stdout
    end

    def elapsed(start)
      (Time.now - start).round(3)
    end
  end
end
