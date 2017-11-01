RSpec.configure do |config|
  # additional factory_girl configuration
  config.before(:suite) do
    begin
      puts 'Running FactoryGirl Linter ...'
      DatabaseCleaner.start
      FactoryGirl.lint
      puts 'Done with Linter'
    ensure
      DatabaseCleaner.clean
    end
  end
end
