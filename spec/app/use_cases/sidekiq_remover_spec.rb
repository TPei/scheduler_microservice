require 'spec_helper'
require 'sidekiq/api'
require 'sidekiq/testing'
require './app/use_cases/sidekiq_remover'

RSpec.describe SidekiqRemover do
  def app
    Api::ApiV1
  end

  describe '.delete_all' do
    it 'dequeues, deschedules and unretries' do
      game_key = '123'
      expect(SidekiqRemover).to receive(:dequeue).with(game_key)
      expect(SidekiqRemover).to receive(:deschedule).with(game_key)
      expect(SidekiqRemover).to receive(:unretry).with(game_key)
      SidekiqRemover.delete_all(game_key)
    end

    it 'returns the | combined result of the separate results' do
      [[false, false, false], [false, true, false], [true, false, true],
       [true, true, true]].each do |a, b, c|
        allow(SidekiqRemover).to receive(:dequeue).and_return(a)
        allow(SidekiqRemover).to receive(:deschedule).and_return(b)
        allow(SidekiqRemover).to receive(:unretry).and_return(c)
        expect(SidekiqRemover.delete_all('')).to eq (a | b | c)
      end
    end
  end

  describe '.dequeue' do
    it 'calls delete with given key and Sidekiq Queue' do
      game_key = '123'
      expect(SidekiqRemover).to receive(:delete).with(Sidekiq::Queue, game_key)
      SidekiqRemover.dequeue(game_key)
    end
  end

  describe '.deschedule' do
    it 'calls delete with given key and Sidekiq ScheduledSet' do
      allow(Sidekiq::ScheduledSet).to receive(:new).and_return(set = double)
      game_key = '123'
      expect(SidekiqRemover).to receive(:delete).with(set, game_key)
      SidekiqRemover.deschedule(game_key)
    end
  end

  describe '.unretry' do
    it 'calls delete with given key and Sidekiq RetrySet' do
      allow(Sidekiq::RetrySet).to receive(:new).and_return(set = double)
      game_key = '123'
      expect(SidekiqRemover).to receive(:delete).with(set, game_key)
      SidekiqRemover.unretry(game_key)
    end
  end

  describe '.delete' do
    before do
      @game_key = 'le_key'
      @non_game_key = 'some_other_key'
    end

    context 'with matching jobs' do
      it 'deletes all jobs for a key from given set' do
        allow(Sidekiq::ScheduledSet).to receive(:new).and_return([job = double])
        allow(job).to receive(:args).and_return([@game_key])
        expect(job).to receive(:delete)
        expect(SidekiqRemover.delete(Sidekiq::ScheduledSet.new, @game_key)).to eq(true)
      end
    end

    context 'with no matching jobs' do
      it 'does nothing' do
        allow(Sidekiq::ScheduledSet).to receive(:new).and_return([job = double])
        allow(job).to receive(:args).and_return([@non_game_key])
        expect(job).not_to receive(:delete)
        expect(SidekiqRemover.delete(Sidekiq::ScheduledSet.new, @game_key)).to eq(false)
      end
    end
  end
end
