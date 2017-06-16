# frozen_string_literal: true

require 'dotenv'
require 'json'
require 'active_support/time'
require 'uri'
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

          unless endpoint && payload && interval != 0 && endpoint =~ URI::regexp
            halt 422 # unprocessable entity
          end

          id = SecureRandom.hex
          ScheduleWorker.perform_in(interval.seconds, id, endpoint, payload, interval)
          [201, { 'id' => id }.to_json]
        end

        delete '/schedule/:id' do
          id = params['id']
          success = SidekiqRemover.delete_all(id)
          response = nil
          code = nil

          if success
            code = 200
            response = { success: true }.to_json
          else
            code = 404
            response = { success: false }.to_json
          end

          [code, response]
        end
      end
    end
  end
end
