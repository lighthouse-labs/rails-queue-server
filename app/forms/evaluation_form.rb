class EvaluationForm
  include ActiveModel::Model

  attr_accessor(
    :evaluation,
    :outcomes
  )

  def initialize(evaluation_model)
    self.evaluation = evaluation_model
    self.outcomes = []
    self.evaluation.project.activities.each do |activity|
      activity.outcomes.each do |outcome|
          self.code_outcomes << {text: outcome.text, mark: 0, outcome_id: outcome.id, activity_id: activity.id}
      end
    end
  end
end
