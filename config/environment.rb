# Load the Rails application.
require File.expand_path('../application', __FILE__)

Rails.logger = ActiveSupport::Logger.new(STDOUT)


# Initialize the Rails application.
Rails.application.initialize!
