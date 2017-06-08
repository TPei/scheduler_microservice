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
      game_key = '123'
      expect(SidekiqRemover).to receive(:delete).with(Sidekiq::ScheduledSet, game_key)
      SidekiqRemover.deschedule(game_key)
    end
  end

  describe '.unretry' do
    it 'calls delete with given key and Sidekiq RetrySet' do
      game_key = '123'
      expect(SidekiqRemover).to receive(:delete).with(Sidekiq::RetrySet, game_key)
      SidekiqRemover.unretry(game_key)
    end
  end

  describe '.delete' do
    before do
      @game_key = 'le_key'
      @non_game_key = 'some_other_key'

      InfectionScheduleWorker.perform_in(100.seconds, @non_game_key, 100)
    end

    after do
      InfectionScheduleWorker.jobs.clear
    end

    context 'with matching jobs' do
      before do
        InfectionScheduleWorker.perform_in(100.seconds, @game_key, 100)
      end

      it 'deletes all jobs for a key from given set' do
        skip
        expect(InfectionScheduleWorker.jobs.size).to eq(2)
        set = Sidekiq::ScheduledSet.new
        expect(SidekiqRemover.delete(set, @game_key)).to eq(true)
        expect(InfectionScheduleWorker.jobs.size).to eq(1)

        jobs_args = InfectionScheduleWorker.jobs.map { |job| job['args'] }.flatten
        expect(jobs_args).not_to include(@game_key)
        expect(jobs_args).to include(@non_game_key)
      end
    end

    context 'with no matching jobs' do
      it 'does nothing' do
        expect(InfectionScheduleWorker.jobs.size).to eq(1)
        set = Sidekiq::ScheduledSet.new
        expect(SidekiqRemover.delete(set, @game_key)).to eq(false)
        expect(InfectionScheduleWorker.jobs.size).to eq(1)

        jobs_args = InfectionScheduleWorker.jobs.map { |job| job['args'] }.flatten
        expect(jobs_args).not_to include(@game_key)
        expect(jobs_args).to include(@non_game_key)
      end
    end
  end
end
