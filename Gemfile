source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

gem 'rails', '~> 6.0.3', '>= 6.0.3.4'
gem 'mysql2', '>= 0.4.4'
gem 'puma', '~> 4.1'
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 4.0'
gem 'jbuilder', '~> 2.7'
gem 'redis', '~> 4.0'
gem 'image_processing', '~> 1.2'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'sidekiq'
gem 'aws-sdk-rails', '~> 3'
gem 'aws-sdk-s3', '~> 1'
gem 'lograge'
gem 'actionpack-cloudfront'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'letter_opener_web', '~> 1.0'
  gem 'annotate'
  gem 'bullet'
end

group :test do
  gem 'rspec-rails', '~> 4.0.1'
  gem 'rspec_junit_formatter'
  gem 'simplecov', require: false
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'rubocop', require: false
  gem "rubocop-performance", require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-airbnb', require: false
  gem 'rails_best_practices'
  gem 'brakeman'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
