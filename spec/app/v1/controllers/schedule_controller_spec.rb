# frozen_string_literal: true

require 'spec_helper'
require 'sidekiq/testing'
require 'dotenv'
require './app/workers/infection_schedule_worker'

RSpec.describe Api::V1::Controllers::ScheduleController do
  def app
    Api::ApiV1
  end

  describe 'GET /schedule' do
    context 'with a game key' do
      before do
        @game_key = 'some game key'
      end

      context 'with time given' do
        before do
          @time = 300
        end

        it 'enqueues infection_schedule_worker appropriately' do
          data = { 'game_key' => @game_key, 'time' => @time }
          post '/schedule', data

          expect(InfectionScheduleWorker).to receive(:perform_async).
            with(@game_key, @time)
          expect(last_response.status).to eq 200
          expect(last_response.body).to eq({ 'success' => true }.to_json)
        end
      end

      context 'without time given' do
        it 'enqueues infection_schedule_worker with default time' do
          data = { 'game_key' => @game_key }
          post '/schedule', data

          expect(InfectionScheduleWorker).to receive(:perform_async).
            with(@game_key, ENV['DEFAULT_INFECTION_TIME'])

          expect(last_response.status).to eq 200
          expect(last_response.body).to eq({ 'success' => true }.to_json)
        end
      end
    end

    context 'without a game key' do
      it 'return a 422' do
        post '/schedule', {}
        expect(last_response.status).to eq 422
      end
    end
  end
end
