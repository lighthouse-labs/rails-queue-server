class EvaluationTransition < ApplicationRecord

  include Statesman::Adapters::ActiveRecordTransition

  belongs_to :evaluation, inverse_of: :evaluation_transitions

  after_destroy :update_most_recent, if: :most_recent?

  private

  def update_most_recent
    last_transition = evaluation.evaluation_transitions.order(:sort_key).last
    return if last_transition.blank?
    last_transition.update_column(:most_recent, true)
  end

end
