# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :recording do
    file_name { Faker::Number.number(10) + '.mp4' }
    recorded_at Time.now.getlocal
    association :presenter, factory: :teacher
    association :cohort
    association :activity
    association :program
  end
end
