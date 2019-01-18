class StopTechInterview

  include Interactor

  def call
    @tech_interview = context.tech_interview
    @user           = context.user # who is stopping the interview
    @location       = @tech_interview.cohort.location

    # FIXME: Doesn't do a permission check using @user
    #        And also should be in a db transaction
    #        See StartTechInterview interactor/service-obj for eg
    #        - KV
    @tech_interview.started_at = nil
    TechInterviewResult.where(tech_interview_id: @tech_interview.id).delete_all

    context.fail!(error: @tech_interview.errors.full_messages.first) unless @tech_interview.save
    RequestQueue::BroadcastUpdateAsync.call(program: Program.first)
  end

  # Not used to change anything in the UI. Commenting out for that reason.
  # Remove me in a future cleanup - KV
  # def broadcast_to_interviewee
  #   UserChannel.broadcast_to @interviewee, type:   "TechInterviewStopped",
  #                                          object: TechInterviewSerializer.new(@tech_interview).as_json
  # end

end
