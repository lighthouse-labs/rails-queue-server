class StartTechInterview

  include Interactor

  def call
    @tech_interview = context.tech_interview
    @interviewer    = context.interviewer
    @interviewee    = @tech_interview.interviewee
    @location       = @tech_interview.cohort.location

    @tech_interview.interviewer = @interviewer
    @tech_interview.started_at = Time.current
    @tech_interview.day = determine_day

    TechInterview.transaction do
      @tech_interview.save!
      create_results
      broadcast_to_queue
      broadcast_to_interviewee
    end
  end

  private

  def broadcast_to_queue
    ActionCable.server.broadcast "assistance-#{@location.name}", type:   "TechInterviewStarted",
                                                                 object: TechInterviewSerializer.new(@tech_interview, root: false).as_json
    BroadcastQueueUpdate.call(program: Program.first)
  end

  def broadcast_to_interviewee
    UserChannel.broadcast_to @interviewee, type:   "TechInterviewStarted",
                                           object: TechInterviewSerializer.new(@tech_interview).as_json
  end

  def determine_day
    # expect to always an interviewee and for them to have a cohort
    CurriculumDay.new(Date.current, @interviewee.cohort).to_s
  end

  def create_results
    unless @tech_interview.results.any?
      @tech_interview.tech_interview_template.questions.active.each do |question|
        @tech_interview.results.create! tech_interview_question: question, question: question.question, sequence: question.sequence
      end
    end
  end

end
