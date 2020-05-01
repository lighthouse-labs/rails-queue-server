class TechInterview::CreateInterviewRecord

  include Interactor

  before do
    @tech_interview = context.tech_interview
    @tech_interview_template = context.tech_interview_template
    @interviewee = context.interviewee || context.tech_interview.interviewee
    @interviewer = context.interviewer
  end

  def call
    @tech_interview ||= @tech_interview_template.pending_interview_for(@interviewee) ||
                    @tech_interview_template.tech_interviews.new(interviewee: @interviewee, cohort: @interviewee.cohort)
    context.fail! unless @tech_interview

    @tech_interview.interviewer = @interviewer
    @tech_interview.started_at = Time.current
    @tech_interview.day =  CurriculumDay.new(Date.current, @interviewee.cohort).to_s
    context.fail! unless @tech_interview.save!
    context.tech_interview = @tech_interview
    
  end

  def rollback
    context.tech_interview.delete
  end

end
