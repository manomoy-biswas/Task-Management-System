source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.6"
gem "bcrypt"
gem "bootsnap", ">= 1.4.2"
gem "bootstrap"
gem "carrierwave", "~> 2.1"
gem "elasticsearch-model"
gem "elasticsearch-rails"
gem "font-awesome-rails", "~> 4.7", ">= 4.7.0.5"
gem "jbuilder", "~> 2.7"
gem "mini_magick", "~> 4.10", ">= 4.10.1"
gem "mysql2", ">= 0.4.4"
gem "omniauth-google-oauth2", "~> 0.8.0"
gem "prawn", "~> 2.2", ">= 2.2.2"
gem "prawn-table", "~> 0.2.2"
gem "puma", "~> 4.3"
gem "rails", "~> 6.0.2", ">= 6.0.2.1"
gem "redis", "~> 4.0"
gem "rubyzip", ">= 1.0.0",require: "zip/zip"
gem "sass-rails", ">= 6"
gem "sidekiq", "~> 6.0", ">= 6.0.7"
gem "sidekiq-scheduler", "~> 3.0", ">= 3.0.1"
gem "slim", "~> 3.0", ">= 3.0.6"
gem "turbolinks", "~> 5"
gem "webpacker", "~> 4.0"
gem "zip-zip"

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "faker", "~> 1.9", ">= 1.9.6"
  gem "letter_opener", "~> 1.7"
  gem "letter_opener_web", "~> 1.4"
  gem 'rspec-rails', '~> 4.0', '>= 4.0.1'
  gem "shoulda-matchers"
  gem 'factory_bot_rails'
  gem 'simplecov', require: false
end

group :development do
  gem "better_errors", "~> 2.5", ">= 2.5.1"
  gem "web-console", ">= 3.3.0"
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :test do
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem 'shoulda-callback-matchers'
end

group :production do
  gem 'bonsai-elasticsearch-rails', github: 'omc/bonsai-elasticsearch-rails', branch: 'master'
  gem "aws-sdk-s3", require: false
  gem "fog"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]