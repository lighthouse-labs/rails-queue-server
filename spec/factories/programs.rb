# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :program do
    name { Faker::Name.name }
    recordings_folder { Faker::Number.number(10) }
    recordings_bucket { Faker::Number.number(10) }
    weeks 8
    days_per_week 5
  end
end
