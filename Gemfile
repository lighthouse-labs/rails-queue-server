source 'https://rubygems.org'
ruby '2.3.0'

gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'

gem 'jquery-rails'
gem 'jquery-ui-rails'

# gem 'turbolinks'
gem 'sdoc', '~> 0.4.0',          group: :doc

gem 'react-rails', '~> 1.4.1'
gem 'active_model_serializers'

gem 'pg'
gem 'bcrypt'
gem 'puma', '~> 3.0'

gem 'kaminari'
# gem 'readmorejs-rails'
gem 'best_in_place', github: 'bernat/best_in_place'
gem 'ace-rails-ap'

gem 'simple_form'
gem 'slim-rails'
gem 'bootstrap-sass', '~> 3.3.5'
gem 'font-awesome-rails'
gem 'compass-rails'

gem 'interactor-rails'

gem 'statesman'
gem 'awesome_print'
gem 'logging'

gem 'redis'

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

gem "sentry-raven"

gem 'rubyzip', '>= 1.0.0'

gem 'slack-poster'

gem 'aws-sdk-core'

gem 'faker'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'rails_layout'
  gem 'letter_opener'
  gem 'letter_opener_web'

  gem 'rb-fchange', :require=>false
  gem 'rb-fsevent', :require=>false
  gem 'rb-inotify', :require=>false
end

group :development, :test do
  gem 'dotenv-rails'

  gem 'byebug', platform: :mri
  gem 'spring-commands-rspec'
  gem 'factory_girl_rails'
  # gem 'rspec-rails', '2.14.2'

end


group :test do
  gem 'capybara'
  gem 'launchy'
  gem 'poltergeist'
  gem 'database_cleaner', '1.0.1'
  gem 'email_spec'
  # gem 'shoulda-matchers' # not ready for 4.1

  # http://d.pr/i/N429/2oGamluY
  gem "codeclimate-test-reporter", require: nil
end

group :production, :staging do
  gem 'rails_12factor'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
