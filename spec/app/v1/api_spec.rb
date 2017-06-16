# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Api::ApiV1 do
  def app
    Api::ApiV1
  end

  describe 'GET /' do
    it 'gives test response' do
      get '/'
      expect(last_response.status).to eq 200
    end
  end

  describe 'GET /documentation' do
    it 'shows the documentation' do
      get '/documentation'
      expect(last_response.status).to eq 200
      expect(last_response.body.
             include?('Scheduler Microservice')).to eq true
      expect(last_response.body.
             include?('<small>version v1</small>')).to eq true
    end
  end
end
