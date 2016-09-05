class MarkTechInterview
  include Interactor

  def call
    @tech_interview = context.tech_interview
    @interviewer    = context.interviewer
    @attributes     = sanitized_params(context.params)

    @tech_interview.assign_attributes(@attributes) if @attributes
    complete(@tech_interview, @interviewer)

    context.fail! unless @tech_interview.save
  end

  private

  def complete(interview, interviewer)
    interview.interviewer = interviewer
    interview.completed_at = Time.current
    calculate_average_score(interview)
  end

  def calculate_average_score(interview)
    interview.average_score = interview.results.where.not(score: nil).average(:score)
  end

  def sanitized_params(params)
    if params.present?
      params.require(:tech_interview).permit(
        :feedback,
        :internal_notes,
        :articulation_score,
        :knowledge_score,
        results_attributes: [:notes, :score, :id]
      )
    end
  end

end
