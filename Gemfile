#for rvm
#ruby=1.9.3
#ruby-gemset=rails_tutorial

source 'https://rubygems.org'

gem 'rails', '3.2.13'
gem 'bootstrap-sass', '2.1'
gem 'haml-rails'
gem 'pry'
gem 'bcrypt-ruby', '3.0.1'
gem 'zeus'
gem 'faker'
gem 'will_paginate', '3.0.3'
gem 'bootstrap-will_paginate', '0.0.6'
gem 'figaro'

group :development, :test do
  gem 'sqlite3', '1.3.5'
  gem 'rspec-rails', '2.11.0'
  gem 'guard-rspec'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '3.2.5'
  gem 'uglifier', '1.2.3'
end

gem 'jquery-rails', '2.0.2'
gem 'coffee-rails', '3.2.2'

group :test do
  gem 'capybara', '1.1.2'
  gem 'rb-inotify'
  gem 'libnotify'
  gem 'factory_girl_rails', '4.1.0'
  gem 'cucumber-rails', '1.2.1', :require => false
  gem 'database_cleaner', '0.7.0'
  gem "shoulda-matchers"
  gem 'launchy'
end

group :production do
  gem 'pg', '0.12.2'
end
group :development do
  gem 'annotate', '2.5.0'
end