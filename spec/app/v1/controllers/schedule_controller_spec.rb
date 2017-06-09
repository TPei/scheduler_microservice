# frozen_string_literal: true

require 'spec_helper'
require 'sidekiq/testing'
require 'dotenv'
require 'active_support/time'
require './app/workers/infection_schedule_worker'
require './app/use_cases/sidekiq_remover'

RSpec.describe Api::V1::Controllers::ScheduleController do
  def app
    Api::ApiV1
  end

  describe 'POST /schedule' do
    before do
      @header = {'CONTENT_TYPE' => 'application/json'}
    end

    context 'with a game key' do
      before do
        @game_key = 'some game key'
      end

      context 'with time given' do
        before do
          @time = 300
        end

        it 'enqueues infection_schedule_worker appropriately' do
          expect(InfectionScheduleWorker).to receive(:perform_in).
            with(@time.seconds, @game_key, @time)

          data = { 'game_key' => @game_key, 'time' => @time }.to_json
          post '/schedule', data, @header

          expect(last_response.status).to eq 201
          expect(last_response.body).to eq({ 'game_key' => @game_key }.to_json)
        end
      end

      context 'without time given' do
        it 'enqueues infection_schedule_worker with default time' do
          time = ENV['DEFAULT_INFECTION_TIME'].to_i

          expect(InfectionScheduleWorker).to receive(:perform_in).
            with(time.seconds, @game_key, time)

          data = { 'game_key' => @game_key }.to_json
          post '/schedule', data, @header

          expect(last_response.status).to eq 201
          expect(last_response.body).to eq({ 'game_key' => @game_key }.to_json)
        end
      end
    end

    context 'without a game key' do
      it 'return a 422' do
        post '/schedule', {}.to_json, @header
        expect(last_response.status).to eq 422
      end
    end
  end

  describe 'DELETE /schedule'  do
    context 'if deleting is successful' do
      before do
        allow(SidekiqRemover).to receive(:delete_all).and_return(true)
      end

      it 'deletes all sidekiq jobs with given game_key' do
        game_key = 'some_key'

        expect(SidekiqRemover).to receive(:delete_all).with(game_key)

        delete "/schedule/#{game_key}"
        expect(last_response.status).to eq 200
      end
    end

    context 'if job is not found' do
      before do
        allow(SidekiqRemover).to receive(:delete_all).and_return(false)
      end

      it 'deletes all sidekiq jobs with given game_key' do
        game_key = 'some_key'

        expect(SidekiqRemover).to receive(:delete_all).with(game_key)

        delete "/schedule/#{game_key}"
        expect(last_response.status).to eq 404
      end
    end
  end
end
