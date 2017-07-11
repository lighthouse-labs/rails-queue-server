class StopTechInterview

  include Interactor

  def call
    @tech_interview = context.tech_interview
    @user           = context.user # who is stopping the interview
    @location       = @tech_interview.cohort.location

    @tech_interview.started_at = nil

    if @tech_interview.save
      broadcast_to_queue
      broadcast_to_interviewee
    else
      context.fail!(error: @tech_interview.errors.full_messages.first)
    end
  end

  private

  def broadcast_to_queue
    ActionCable.server.broadcast "assistance-#{@location.name}", type:   "TechInterviewStopped",
                                                                 object: TechInterviewSerializer.new(@tech_interview, root: false).as_json
  end

  def broadcast_to_interviewee
    UserChannel.broadcast_to @interviewee, type:   "TechInterviewStopped",
                                           object: TechInterviewSerializer.new(@tech_interview).as_json
  end

end
