require 'sidekiq'
require 'unirest'
require 'dotenv'
require 'active_support/time'

class ScheduleWorker
  include Sidekiq::Worker

  def perform(id, endpoint, payload, interval)
    Unirest.post(
      endpoint,
      parameters: payload
    )

    ScheduleWorker.perform_in(interval.seconds, id, endpoint, payload, interval)
  end
end
