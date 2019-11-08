FactoryBot.define do
  factory :programming_test_attempt, class: 'ProgrammingTest::Attempt' do
    student nil
    cohort nil
    programming_test nil
    token ""
    state "MyString"
    error "MyString"
  end
end
