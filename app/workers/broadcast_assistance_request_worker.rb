class BroadcastAssistanceRequestWorker

  include Sidekiq::Worker

  # Don't want it to retry a failed deployment. Move on!
  # https://github.com/mperham/sidekiq/wiki/Error-Handling
  sidekiq_options retry: false

  def perform(assistance_request_id)
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
