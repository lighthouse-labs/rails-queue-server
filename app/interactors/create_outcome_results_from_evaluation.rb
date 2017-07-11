class CreateOutcomeResultsFromEvaluation

  include Interactor

  def call
    outcomes = context.evaluation_form[:outcomes]
    if outcomes
      OutcomeResult.transaction do
        outcomes.each do |_key, outcome|
          next if outcome[:mark].blank?
          OutcomeResult.create!(outcome_id:  outcome[:id],
                                rating:      outcome[:mark],
                                source_id:   outcome[:activity_id],
                                source_type: "Activity",
                                user:        context.evaluation.student)
        end
      end
    end
  rescue ActiveRecord::RecordInvalid => exception
    context.fail!(error: exception.message)
  end

end
