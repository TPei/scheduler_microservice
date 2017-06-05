# frozen_string_literal: true

require 'dotenv'
require 'json'
require './app/workers/infection_schedule_worker'

module Api
  module V1
    module Controllers
      class ScheduleController < Sinatra::Base
        post '/schedule' do
          body = JSON.load(request.body.read)
          unless key = body['game_key']
            halt 422 # unprocessable entity
          end

          time = body['time'] || ENV['DEFAULT_INFECTION_TIME']
          InfectionScheduleWorker.perform_async(key, time)
        end
      end
    end
  end
end
