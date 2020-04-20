source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.5"
gem "bcrypt"
gem "rails", "~> 6.0.2", ">= 6.0.2.1"
gem "mysql2", ">= 0.4.4"
gem "puma", "~> 4.1"
gem "sass-rails", ">= 6"
gem "webpacker", "~> 4.0"
gem "turbolinks", "~> 5"
gem "jbuilder", "~> 2.7"
gem "redis", "~> 4.0"
gem "bootsnap", ">= 1.4.2"
gem "bootstrap", "~> 4.4", ">= 4.4.1"
gem "jquery-rails", "~> 4.3", ">= 4.3.5"
gem "popper_js", "~> 1.16"
gem "font-awesome-rails", "~> 4.7", ">= 4.7.0.5"
gem "omniauth-google-oauth2", "~> 0.8.0"
gem "paperclip", "~> 6.1"
gem 'daemons', '~> 1.3', '>= 1.3.1'
gem "delayed_job_active_record"
gem "bootstrap-email"
gem 'sidekiq', '~> 6.0', '>= 6.0.7'
gem 'sidekiq-scheduler', '~> 3.0', '>= 3.0.1'

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "faker", "~> 1.9", ">= 1.9.6"
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
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]