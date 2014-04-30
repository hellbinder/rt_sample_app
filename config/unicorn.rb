before_fork do |server, worker|
   @sidekiq_pid ||= spawn("bundle exec sidekiq -c 3")
end