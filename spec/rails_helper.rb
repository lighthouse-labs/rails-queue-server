# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'

# Can't use Rails.root here b/c environment is loaded later, hence the ugliness
require File.join(File.dirname(__FILE__), 'support', 'simplecov')

require File.expand_path('../../config/environment', __FILE__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
require 'email_spec'
require 'database_cleaner'

# REQUIRE SUPPORT FILES

# Factory Girl Setup
# For single tests, don't run the factory girl linter
# TODO: Turn me on
# unless RSpec.configuration.inclusion_filter.rules.any?
#   require Rails.root.join('spec/support/factory_bot_linter')
# end
require Rails.root.join('spec/support/factory_bot_syntax')

require Rails.root.join('spec/support/oauth')
require Rails.root.join('spec/support/user_account_helpers')
require Rails.root.join('spec/support/capybara_selenium')

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

# Removes intrusive ActiveRecord SQL logger
ActiveRecord::Base.logger.level = 'warn'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
# Dir[Rails.root.join("spec", "support", "**", "*.rb")].each {|f| require f}

RSpec.configure do |config|

  config.infer_spec_type_from_file_location!
  # For now, we don't test views separately.
  config.include RSpec::Rails::ViewRendering
  config.include FactoryBot::Syntax::Methods
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers

  config.include UserAccountHelpers, type: :controller
  config.extend  UserAccountHelpers::Macros, type: :controller

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Built in alternative to Timecop
  config.include ActiveSupport::Testing::TimeHelpers

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # As per: http://blog.yux.ch/blog/2013/01/19/javascript-tests-with-phantomjs/
  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
    # TODO: Repeated from above (remove one or the other)
    Capybara.javascript_driver = ENV['HEADLESS'] == '0' ? :chrome : :headless_chrome

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(GITHUB_OAUTH_HASH)
  end
  config.before :each do
    if RSpec.current_example.metadata[:js]
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start
    end
  end
  config.after :each do
    DatabaseCleaner.clean
  end
end
