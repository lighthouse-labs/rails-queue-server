class BroadcastAssistanceRequestWorker

  include Sidekiq::Worker

  # Don't want it to retry failed websocket updates. Move on!
  # https://github.com/mperham/sidekiq/wiki/Error-Handling
  sidekiq_options retry: false, queue: 'realtime'

  def perform(assistance_request_id)
    request   = AssistanceRequest.find assistance_request_id
    requestor = request.requestor

    # Let the student know that they are indeed in the queue now (and their position)
    UserChannel.broadcast_to requestor, type:   "AssistanceRequested",
                                        object: requestor.position_in_queue

    # Location specific b/c it's the stream used to
    # trigger desktop notifications for teachers/assistors on the queue
    if (location_name = request.assistor_location&.name)
      ActionCable.server.broadcast "assistance-#{location_name}", type:   "AssistanceRequest",
                                                                  object: AssistanceRequestSerializer.new(request, root: false).as_json
    end

    # Let the assistors know by updating the queue
    RequestQueue::BroadcastUpdate.call(program: Program.first)
  end

end
