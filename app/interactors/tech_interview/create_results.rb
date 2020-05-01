class TechInterview::CreateResults

  include Interactor

  before do
    @tech_interview = context.tech_interview
  end

  def call
    unless @tech_interview.results.any?
      @tech_interview.tech_interview_template.questions.active.each do |question|
        @tech_interview.results.create! tech_interview_question: question, question: question.question, sequence: question.sequence
      end
    end
  end

  def rollback
    context.tech_interview.results.delete_all
  end

end
