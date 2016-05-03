class EvaluationForm
  include ActiveModel::Model

  attr_accessor :evaluation, :outcomes

  def initialize(evaluation_model)
    @evaluation = evaluation_model
    @outcomes = []
    @evaluation.project.activities.each do |activity|
      activity.outcomes.each do |outcome|
        @outcomes << { text: outcome.text, mark: 0, id: outcome.id, activity_id: activity.id }
      end
    end
  end
end
