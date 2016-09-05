class StartTechInterview
  include Interactor

  def call
    @tech_interview = context.tech_interview
    @interviewer    = context.interviewer
    @interviewee    = @tech_interview.interviewee

    @tech_interview.interviewer = interviewer
    @tech_interview.started_at = Time.current
    @tech_interview.day = determine_day

    TeachInterview.transaction do
      @tech_interview.save!



  end

  private


  def determine_day
    # expect to always an interviewee and for them to have a cohort
    CurriculumDay.new(Date.current, @interviewee.cohort).to_s
  end

  def create_results
    tech_interview_template.questions.each do |question|
      self.results.create! tech_interview_question: question, question: question.question, sequence: question.sequence
    end
  end

end
