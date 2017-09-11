# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :cohort do
    name { Faker::Name.name }
    start_date { Date.current }
    code { Faker::Superhero.name.parameterize }
    association :location
    association :program
  end
end
