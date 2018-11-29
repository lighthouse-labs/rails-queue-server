class BroadcastAssistanceStartWorker

  include Sidekiq::Worker

  # Don't want it to retry a failed deployment. Move on!
  # https://github.com/mperham/sidekiq/wiki/Error-Handling
  sidekiq_options retry: false

  def perform(request_id, assistor_id)
    assistor = User.find assistor_id
    request = AssistanceRequest.find request_id

    if location_name = request.assistor_location&.name
      ActionCable.server.broadcast "assistance-#{location_name}", type:   "AssistanceStarted",
                                                                  object: AssistanceSerializer.new(request.assistance, root: false).as_json
    end

    UserChannel.broadcast_to request.requestor, type: "AssistanceStarted", object: UserSerializer.new(assistor).as_json

    RequestQueue::BroadcastTeacherBusy.call(assistor: assistor)
    RequestQueue::BroadcastNewQueuePositions.call(location: request.assistor_location)

    # technically it should not do Program.first here, but wtv. Shouldn't cause issues - KV
    # I do need to figure out what object is better to send in there actually
    RequestQueue::BroadcastUpdate.call(program: Program.first)
  end

end
