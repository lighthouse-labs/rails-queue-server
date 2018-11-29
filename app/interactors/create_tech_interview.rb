class CreateTechInterview

  include Interactor

  def call
    @interviewee = context.interviewee
    @interview_template = context.interview_template

    @location = @interviewee.cohort.location

    @tech_interview = context.tech_interview = @interview_template.tech_interviews.new(
      interviewee: @interviewee
    )

    if @tech_interview.save
      broadcast_to_queue
      broadcast_to_interviewee
    else
      context.fail!(error: @tech_interview.errors.full_messages.first)
    end
  end

  private

  def broadcast_to_queue
    ActionCable.server.broadcast "assistance-#{@location.name}", type:   "NewTechInterview",
                                                                 object: TechInterviewSerializer.new(@tech_interview, root: false).as_json
    RequestQueue::BroadcastUpdate.call(program: Program.first)
  end

  def broadcast_to_interviewee
    UserChannel.broadcast_to @interviewee, type: "TechInterviewQueued", object: TechInterviewSerializer.new(@tech_interview).as_json
  end

end
