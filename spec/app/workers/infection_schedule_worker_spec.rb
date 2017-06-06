# frozen_string_literal: true

require 'spec_helper'
require 'dotenv'
require 'active_support/time'
require 'sidekiq/testing'

RSpec.describe InfectionScheduleWorker do
  def app
    Api::ApiV1
  end

  describe 'perform' do
    before do
      allow(Unirest).to receive(:post)
    end

    it 'calls an endpoint on the main app and reenqueues itself' do
      time = 500
      key = 'some key'

      expect(Unirest).to receive(:post).
        with(
          "#{ENV['MAIN_SERVICE_URL']}/game/infection",
          parameters: { game_key: key }
        )

      expect(InfectionScheduleWorker).to receive(:perform_in).
        with(time.seconds, key, time)

      InfectionScheduleWorker.new.perform(key, time)
    end
  end
end

