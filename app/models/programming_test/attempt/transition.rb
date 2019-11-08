class ProgrammingTest::Attempt::Transition < ApplicationRecord
  include Statesman::Adapters::ActiveRecordTransition

  belongs_to :attempt, class_name: 'ProgrammingTest::Attempt', inverse_of: :programming_test_attempt_transitions

  after_destroy :update_most_recent, if: :most_recent?

  private

  def update_most_recent
    last_transition = attempt.transitions.order(:sort_key).last
    return unless last_transition.present?
    last_transition.update_column(:most_recent, true)
  end
end
