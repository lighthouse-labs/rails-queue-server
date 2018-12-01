class BroadcastAssistanceCancelWorker

  include Sidekiq::Worker

  # Don't want it to retry failed websocket updates. Move on!
  # https://github.com/mperham/sidekiq/wiki/Error-Handling
  sidekiq_options retry: false

  # Passing in assistance_request since we destroyed (yikes!) the assistance in question
  def perform(request_id, assistor_id)
    request  = AssistanceRequest.find request_id
    assistor = User.find assistor_id

    RequestQueue::BroadcastUpdate.call(program: Program.first)
    RequestQueue::BroadcastTeacherAvailable.call(assistor: assistor)
    RequestQueue::BroadcastNewQueuePositions.call(location: request.assistor_location)
  end

end
