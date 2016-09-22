class MarkTechInterview
  include Interactor

  def call
    @tech_interview = context.tech_interview
    @interviewer    = context.interviewer
    @attributes     = sanitized_params(context.params)

    @tech_interview.assign_attributes(@attributes) if @attributes
    complete(@tech_interview, @interviewer)

    if @tech_interview.save
      create_feedback(@tech_interview)
      send_email_to_student(@tech_interview)
    else
      context.fail! error: @tech_interview.errors.full_messages.first
    end
  end

  private

  def complete(interview, interviewer)
    interview.interviewer = interviewer
    interview.completed_at = Time.current
    calculate_average_score(interview)
  end

  def send_email_to_student(interview)
    UserMailer.new_tech_interview_message(interview).deliver
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

  def create_feedback(tech_interview)
    tech_interview.create_student_feedback(student: tech_interview.interviewee, teacher: tech_interview.interviewer)
  end


end
