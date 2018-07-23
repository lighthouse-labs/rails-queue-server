# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :day_feedback do
    mood false
    title "MyString"
    text "MyText"
  end
end
