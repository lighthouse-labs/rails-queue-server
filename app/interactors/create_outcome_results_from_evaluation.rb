class CreateOutcomeResultsFromEvaluation
  include Interactor

  def call
    outcomes = context.outcomes
    OutcomeResult.transaction do
      outcomes.each do |outcome|
        OutcomeResult.create!(outcome_id: outcome[:id],
                             rating: outcome[:mark],
                             source_id: outcome[:activity_id],
                             source_type: "Activity"
                             )
      end
    end
    rescue ActiveRecord::RecordInvalid => exception
      context.fail!(error: exception.message)
  end
end
