# frozen_string_literal: true

require 'spec_helper'
require 'sidekiq/testing'
require 'dotenv'
require 'active_support/time'
require './app/workers/schedule_worker'
require './app/use_cases/sidekiq_remover'

RSpec.describe Api::V1::Controllers::ScheduleController do
  def app
    Api::ApiV1
  end

  describe 'POST /schedule' do
    before do
      @header = {'CONTENT_TYPE' => 'application/json'}
      @body = {
        endpoint: 'http://some_url.com',
        payload: {},
        interval: 100
      }
    end

    context 'with valid data' do
      it 'enqueues schedule_worker appropriately' do
        expect(ScheduleWorker).to receive(:perform_in).
          with(@body[:interval], @body[:endpoint], @body[:payload], @body[:interval])

        post '/schedule', @body.to_json, @header

        expect(last_response.status).to eq 201
      end

      it 'returns a length 16 hex id' do
        expect(ScheduleWorker).to receive(:perform_in).
          with(@body[:interval], @body[:endpoint], @body[:payload], @body[:interval])

        post '/schedule', @body.to_json, @header

        expect(last_response.status).to eq 201
        body = last_response.body
        expect(JSON.parse(body)['id']).to match(/[0-9a-fA-F]{16}/)
      end
    end

    context 'with necessary key missing' do
      it 'return a 422' do
        post '/schedule', {}.to_json, @header
        expect(last_response.status).to eq 422
      end
    end

    context 'with interval = 0' do
      it 'return a 422' do
        post '/schedule', { endpoint: '', payload: {}, interval: 0 }.to_json, @header
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
        id = 'some_id'

        expect(SidekiqRemover).to receive(:delete_all).with(id)

        delete "/schedule/#{id}"
        expect(last_response.status).to eq 200
      end
    end

    context 'if job is not found' do
      before do
        allow(SidekiqRemover).to receive(:delete_all).and_return(false)
      end

      it 'deletes all sidekiq jobs with given game_key' do
        id = 'some_id'

        expect(SidekiqRemover).to receive(:delete_all).with(id)

        delete "/schedule/#{id}"
        expect(last_response.status).to eq 404
      end
    end
  end
end
