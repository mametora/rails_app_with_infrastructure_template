Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{ENV['KVS_HOST']}:6379/2" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{ENV['KVS_HOST']}:6379/2" }
end
