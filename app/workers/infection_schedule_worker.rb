require 'sidekiq'

class InfectionScheduleWorker
  include Sidekiq::Worker

  def perform(key, time)
  end
end
