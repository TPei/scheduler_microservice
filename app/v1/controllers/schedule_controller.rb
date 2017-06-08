# frozen_string_literal: true

require 'dotenv'
require 'json'
require 'active_support/time'
require './app/workers/infection_schedule_worker'
require './app/use_cases/sidekiq_remover'

module Api
  module V1
    module Controllers
      class ScheduleController < Sinatra::Base
        post '/schedule' do
          body = JSON.load(request.body.read)
          unless key = body['game_key']
            halt 422 # unprocessable entity
          end

          time = (body['time'] || ENV['DEFAULT_INFECTION_TIME']).to_i
          InfectionScheduleWorker.perform_in(time.seconds, key, time)
          [201, { 'game_key' => key }.to_json]
        end

        delete '/schedule/:game_key' do
          game_key = params['game_key']
          success = SidekiqRemover.dequeue(game_key)
          success |= SidekiqRemover.deschedule(game_key)
          code = 404
          code = 200 if success
          [code, { 'game_key' => game_key }.to_json]
        end
      end
    end
  end
end
