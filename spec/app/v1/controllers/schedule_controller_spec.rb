# frozen_string_literal: true

require 'spec_helper'
require 'json'
require 'sidekiq/testing'

RSpec.describe Api::V1::Controllers::ScheduleController do
  def app
    Api::ApiV1
  end

  describe 'GET /schedule' do
    it 'returns a basic hello world response' do
      get '/schedule'
      expect(last_response.status).to eq 200
      expect(last_response.body).to eq 'Hello World'
    end
  end
end
