# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :feedback do
    student_id 1
    teacher_id 1
    technical_rating 1
    style_rating 1
    notes "MyText"
  end
end
