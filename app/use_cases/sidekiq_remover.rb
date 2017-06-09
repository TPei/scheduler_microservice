require 'sidekiq/api'

class SidekiqRemover
  def self.delete_all(game_key)
    success = dequeue(game_key)
    success |= deschedule(game_key)
    success |= unretry(game_key)
    success
  end

  def self.dequeue(game_key)
    queue = Sidekiq::Queue.new
    delete(queue, game_key)
  end

  def self.deschedule(game_key)
    ss = Sidekiq::ScheduledSet.new
    delete(ss, game_key)
  end

  def self.unretry(game_key)
    rs = Sidekiq::RetrySet.new
    delete(rs, game_key)
  end

  def self.delete(set, arg)
    success = false
    set.each do |job|
      if job.args.include?(arg)
        job.delete
        success = true
      end
    end
    success
  end
end
