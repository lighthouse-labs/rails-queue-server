# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :activity_feedback do
    activity
    user
    detail "Cool cool"
    rating 5
  end
end