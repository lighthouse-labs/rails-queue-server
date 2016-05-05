class CreateOutcomeResultsFromEvaluation
  include Interactor

  def call
    outcomes = context.evaluation_form[:outcomes]
    OutcomeResult.transaction do
      outcomes.each do |key, outcome|
        OutcomeResult.create!(outcome_id: outcome[:id],
                             rating: outcome[:mark],
                             source_id: outcome[:activity_id],
                             source_type: "Activity",
                             user: context.evaluation.student
                             )
      end
    end
    rescue ActiveRecord::RecordInvalid => exception
      context.fail!(error: exception.message)
  end
end
