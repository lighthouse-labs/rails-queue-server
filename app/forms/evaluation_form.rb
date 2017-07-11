class EvaluationForm

  include ActiveModel::Model

  attr_accessor :evaluation, :outcomes, :teacher_notes, :final_score

  def initialize(evaluation_model)
    @evaluation = evaluation_model

    @outcomes = {}
    @evaluation.project.activities.active.chronological.each do |activity|
      activity.outcomes.excluding_knowledge.each do |outcome|
        @outcomes[outcome.id] ||= { text: outcome.text, mark: 0, id: outcome.id, activity_id: activity.id }
      end
    end
  end

end
