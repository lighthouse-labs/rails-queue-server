source 'https://rubygems.org'
ruby '2.4.3'

gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'

gem 'jquery-rails'
gem 'bootstrap', '~> 4.0.0'
gem 'jquery-ui-rails'

gem "select2-rails"

gem 'turbolinks', '~> 5'
gem 'sdoc', '~> 0.4.0',          group: :doc

gem 'rack-cors'

gem 'react-rails'
gem 'active_model_serializers', '0.9.7'

gem 'pg'
gem 'bcrypt'
gem 'puma', '~> 3.0'

gem 'kaminari'
gem 'bootstrap4-kaminari-views'
# gem 'readmorejs-rails'
gem 'best_in_place', github: 'bernat/best_in_place'
gem 'ace-rails-ap'

gem 'simple_form'
gem 'sidekiq'
gem 'slim-rails'
gem 'font-awesome-rails'
# gem 'compass-rails'

gem 'interactor-rails'

gem 'statesman'
gem 'awesome_print'
gem 'logging'

gem 'redis'

gem 'inky-rb', require: 'inky'
gem 'premailer-rails'
gem 'email_validator'

gem 'redcarpet'
gem 'teaspoon-mocha'
gem 'phantomjs'

gem 'omniauth'
gem 'omniauth-github'

gem 'octokit'

gem 'default_value_for'

gem 'carrierwave'
gem 'mini_magick'
gem 'fog'

gem 'newrelic_rpm'
gem "sentry-raven"

gem 'responders'
gem 'rubyzip', '>= 1.0.0'

gem 'slack-poster'

gem 'aws-sdk-core'

gem 'faker'

gem 'youtube_addy'

gem 'bootsnap', require: false

## charting / data analytics stuff
gem 'groupdate'
gem 'chartkick'

gem 'pg_search'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'rubocop'
  # listen creates too many fsevent_watch processes and kills my laptop. Removing this until resolved - KV
  # gem 'listen', '~> 3.1.5'
  gem 'spring-watcher-listen', '~> 2.0.1'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'rails_layout'
  gem 'letter_opener'
  gem 'letter_opener_web'
  gem 'rb-fchange', :require=>false
  gem 'rb-fsevent', :require=>false
  gem 'rb-inotify', :require=>false
end

group :development, :test do
  gem 'pry-byebug'
  gem 'dotenv-rails'
  gem 'spring-commands-rspec'
  gem 'factory_bot_rails'
  gem 'rspec-rails', '~> 3.6'
  gem 'rspec-collection_matchers'
  gem 'rails-controller-testing'
  gem 'database_cleaner'
end


group :test do
  gem 'capybara'
  # https://robots.thoughtbot.com/headless-feature-specs-with-chrome
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
  gem 'email_spec'
  # gem 'shoulda-matchers' # not ready for 4.1

  gem 'simplecov', require: nil
  # http://d.pr/i/N429/2oGamluY
  gem "codeclimate-test-reporter", require: nil
end

group :production, :staging do
  gem 'rails_12factor'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
