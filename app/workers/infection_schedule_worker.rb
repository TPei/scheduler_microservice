require 'sidekiq'
require 'unirest'
require 'dotenv'
require 'active_support'

class InfectionScheduleWorker
  include Sidekiq::Worker

  def perform(game_key, time)
    Unirest.post(
      "#{ENV['MAIN_SERVICE_URL']}/game/infection",
      parameters: { game_key: game_key }
    )

    InfectionScheduleWorker.perform_in(time.seconds, key, time)
  end
end
