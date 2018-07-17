# methods like `FactoryBot.create` can now just be called as `create`

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
