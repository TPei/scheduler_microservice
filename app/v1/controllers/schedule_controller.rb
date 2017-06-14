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

          ScheduleWorker.perform_in(interval.seconds, endpoint, payload, interval)
          [201, { 'id' => SecureRandom.hex }.to_json]
        end

        delete '/schedule/:id' do
          id = params['id']
          success = SidekiqRemover.delete_all(id)
          payload = nil
          code = nil
          if succes
            code = 200
            payload = { success: true }.to_json
          else
            code = 404
            payload = { success: false }.to_json
          end
          [code, { 'id' => id }.to_json]
        end
      end
    end
  end
end
