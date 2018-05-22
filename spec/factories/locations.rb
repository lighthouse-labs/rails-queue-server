# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :location, aliases: [:vancouver, :toronto] do
    name 'Vancouver'
    timezone 'Pacific Time (US & Canada)'
  end
end
