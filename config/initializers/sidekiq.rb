Rails.application.config.active_job.queue_adapter = :sidekiq

REDIS_URL = ENV['REDIS_URL'] || 'redis://localhost:6379/0'

redis_conn = proc {
  Redis.new(url: REDIS_URL)
}

$redis_pool = ConnectionPool.new(size: 10, &redis_conn)

Sidekiq.configure_server do |config|
  config.redis = { url: REDIS_URL } # ConnectionPool.new(size: 25, &redis_conn)
end

Sidekiq.configure_client do |config|
  config.redis = { url: REDIS_URL } # ConnectionPool.new(size: 25, &redis_conn)
end
