# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :location, aliases: [:vancouver, :toronto] do
    name 'Vancouver'
    timezone 'Pacific Time (US & Canada)'
  end
end
