# CHROME HEADLESS WITH SELENIUM SETUP
# => https://robots.thoughtbot.com/headless-feature-specs-with-chrome
require 'capybara/rails'
require "selenium/webdriver"

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w[headless disable-gpu no-sandbox] }
  )

  Capybara::Selenium::Driver.new app,
                                 browser:              :chrome,
                                 desired_capabilities: capabilities
end
