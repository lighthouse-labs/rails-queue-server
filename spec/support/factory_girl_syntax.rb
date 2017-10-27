# methods like `FactoryGirl.create` can now just be called as `create`

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
