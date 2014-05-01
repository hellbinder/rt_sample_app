require 'sidekiq'
before_fork do |server, worker|
   @sidekiq_pid ||= spawn("bundle exec sidekiq -c 3")
end

worker_processes 2

after_fork do |server, worker|
  Sidekiq.configure_client do |config|
    config.redis = { :size => 1 }
  end
end