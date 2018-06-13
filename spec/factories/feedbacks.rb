# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :feedback do
    student
    teacher
    technical_rating 1
    style_rating 1
    notes "MyText"
  end
end
