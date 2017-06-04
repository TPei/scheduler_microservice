# frozen_string_literal: true

module Api
  module V1
    module Controllers
      class ScheduleController < Sinatra::Base
        get '/schedule' do
          'Hello World'
        end
      end
    end
  end
end
