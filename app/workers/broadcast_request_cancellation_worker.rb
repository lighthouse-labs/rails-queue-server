class BroadcastRequestCancellationWorker

  include Sidekiq::Worker

  # Don't want it to retry a failed deployment. Move on!
  # https://github.com/mperham/sidekiq/wiki/Error-Handling
  sidekiq_options retry: false

  def perform(assistance_request_id)
    assistance_request = AssistanceRequest.find assistance_request_id
    location_name = assistance_request.assistor_location.name || 'Vancouver'

    ActionCable.server.broadcast "assistance-#{location_name}", type:   "CancelAssistanceRequest",
                                                                object: AssistanceRequestSerializer.new(assistance_request, root: false).as_json

    UserChannel.broadcast_to current_user, type: "AssistanceEnded"
    RequestQueue::BroadcastUpdate.call(program: Program.first)

    teacher_available(ar.assistance.assistor) if ar.assistance
    update_students_in_queue(ar.requestor.cohort.location)
    request   = AssistanceRequest.find assistance_request_id
    requestor = request.requestor
    UserChannel.broadcast_to requestor, type:   "AssistanceRequested",
                                        object: requestor.position_in_queue

    if location_name = request.assistor_location&.name
      ActionCable.server.broadcast "assistance-#{location_name}", type:   "AssistanceRequest",
                                                                  object: AssistanceRequestSerializer.new(request, root: false).as_json
    end

    RequestQueue::BroadcastUpdate.call(program: Program.first)
  end

end





