class CreateTechInterview

  include Interactor

  def call
    @interviewee = context.interviewee
    @interview_template = context.interview_template

    @location = @interviewee.cohort.location

    @tech_interview = context.tech_interview = @interview_template.tech_interviews.new(
      interviewee: @interviewee
    )

    context.fail!(error: @tech_interview.errors.full_messages.first) unless @tech_interview.save
    RequestQueue::BroadcastUpdateAsync.call(program: Program.first)
  end

  # Not used/consumed by UI at all. Remove in next cleanup - KV
  # def broadcast_to_interviewee
  #   UserChannel.broadcast_to @interviewee, type: "TechInterviewQueued", object: TechInterviewSerializer.new(@tech_interview).as_json
  # end

end
