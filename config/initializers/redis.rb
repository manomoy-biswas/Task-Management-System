redis = Redis.new(url: ENV["REDIS_URL"])
Redis.exists_returns_integer = true if Gem::Version.new(Sidekiq::VERSION) < Gem::Version.new('6.1')