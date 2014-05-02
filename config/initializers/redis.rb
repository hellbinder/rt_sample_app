# uri = URI.parse(ENV["REDISTOGO_URL"] || "redis://localhost:6379/")
uri = URI.parse("redis://redistogo:5968e16f1b51903c16e949f7a9dd1863@grideye.redistogo.com:10683")
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)