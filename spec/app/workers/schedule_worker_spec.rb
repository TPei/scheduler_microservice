# frozen_string_literal: true

require 'spec_helper'
require 'dotenv'
require 'active_support/time'
require 'sidekiq/testing'

RSpec.describe ScheduleWorker do
  def app
    Api::ApiV1
  end

  describe 'perform' do
    before do
      allow(Unirest).to receive(:post)
    end

    it 'calls an endpoint on the main app and reenqueues itself' do
      endpoint = 'http://www.some_endpoint.com'
      payload = { key: 'value' }
      interval = 500
      id = 'some_id'

      expect(Unirest).to receive(:post).
        with(
          endpoint,
          parameters: payload
        )

      expect(ScheduleWorker).to receive(:perform_in).
        with(interval.seconds, id, endpoint, payload, interval)

      ScheduleWorker.new.perform(id, endpoint, payload, interval)
    end
  end
end

