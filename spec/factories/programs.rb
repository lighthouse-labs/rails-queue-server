# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :program do
    name { Faker::Name.name }
    weeks 8
    days_per_week 5
    curriculum_team_email "curriculum@team.com"
  end
end
