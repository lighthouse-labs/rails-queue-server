class CreateOutcomeResultsFromTechInterview

  include Interactor

  def call
    interview = context.tech_interview

    OutcomeResult.transaction do
      interview.results.each do |result|
        next unless result.score? && result.tech_interview_question.outcome
        OutcomeResult.create!(
          outcome:     result.tech_interview_question.outcome,
          rating:      result.score,
          source:      result,
          source_name: "TechInterview",
          user:        interview.interviewee
        )
      end
    end
  rescue ActiveRecord::RecordInvalid => exception
    context.fail!(error: exception.message)
  end

end
