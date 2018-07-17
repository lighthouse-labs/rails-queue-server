RSpec.configure do |config|
  # additional factory_bot configuration
  config.before(:suite) do
    begin
      puts 'Running FactoryBot Linter ...'
      DatabaseCleaner.start
      FactoryBot.lint
      puts 'Done with Linter'
    ensure
      DatabaseCleaner.clean
    end
  end
end
