class BroadcastRequestCancellationWorker

  include Sidekiq::Worker

  # Don't want it to retry failed websocket updates. Move on!
  # https://github.com/mperham/sidekiq/wiki/Error-Handling
  sidekiq_options retry: false, queue: 'realtime'

  def perform(assistance_request_id)
    request   = AssistanceRequest.find assistance_request_id
    requestor = request.requestor
    location_name = request.assistor_location.name || 'Vancouver'

    RequestQueue::BroadcastUpdate.call(program: Program.first)
    UserChannel.broadcast_to requestor, type: "AssistanceEnded"

    RequestQueue::BroadcastTeacherAvailable.call(assistor: request.assistance.assistor) if request.assistance
    RequestQueue::BroadcastNewQueuePositions.call(location: request.assistor_location)
  end

end
