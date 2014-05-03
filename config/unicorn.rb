require 'sidekiq'
before_fork do |server, worker|
   @sidekiq_pid ||= spawn("bundle exec sidekiq -c 3")
end

worker_processes 3

after_fork do |server, worker|
  Sidekiq.configure_client do |config|
    config.redis = { :size => 1, :url => 'redis://redistogo:5968e16f1b51903c16e949f7a9dd1863@grideye.redistogo.com:10683' }
  end
  Sidekiq.configure_server do |config|
    config.redis = { :size => 2, :url => redis://redistogo:5968e16f1b51903c16e949f7a9dd1863@grideye.redistogo.com:10683 }
  end
end