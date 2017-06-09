# frozen_string_literal: true

require 'dotenv'
require 'json'
require 'active_support/time'
require './app/workers/schedule_worker'
require './app/use_cases/sidekiq_remover'

module Api
  module V1
    module Controllers
      class ScheduleController < Sinatra::Base
        post '/schedule' do
          body = JSON.load(request.body.read)

          endpoint = body['endpoint']
          payload = body['payload']
          interval = body['interval'].to_i

          unless endpoint && payload && interval != 0
            halt 422 # unprocessable entity
          end

          ScheduleWorker.perform_in(interval.seconds, endpoint, payload, interval)
          [201, { 'id' => SecureRandom.hex }.to_json]
        end

        delete '/schedule/:id' do
          id = params['id']
          success = SidekiqRemover.delete_all(id)
          code = 404
          code = 200 if success
          [code, { 'id' => id }.to_json]
        end
      end
    end
  end
end
