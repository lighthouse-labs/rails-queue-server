class BroadcastAssistanceStartWorker

  include Sidekiq::Worker

  # Don't want it to retry failed websocket updates. Move on!
  # https://github.com/mperham/sidekiq/wiki/Error-Handling
  sidekiq_options retry: false

  def perform(request_id, assistor_id)
    assistor = User.find assistor_id
    request = AssistanceRequest.find request_id

    # Let the student know it's started
    UserChannel.broadcast_to request.requestor, type: "AssistanceStarted", object: UserSerializer.new(assistor).as_json
    # The teacher is now busy
    RequestQueue::BroadcastTeacherBusy.call(assistor: assistor)
    # Everyone in the queue should have their position changed
    RequestQueue::BroadcastNewQueuePositions.call(location: request.assistor_location)
    # Update the req queue for all teachers
    # - Technically it should not do Program.first here, but wtv. Shouldn't cause issues - KV
    # - I do need to figure out what object is better to send in there actually
    RequestQueue::BroadcastUpdate.call(program: Program.first)
  end

end
