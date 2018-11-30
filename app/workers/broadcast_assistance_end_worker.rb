class BroadcastAssistanceEndWorker

  include Sidekiq::Worker

  # Don't want it to retry failed websocket updates. Move on!
  # https://github.com/mperham/sidekiq/wiki/Error-Handling
  sidekiq_options retry: false

  def perform(assistance_id)
    assistance = Assistance.find assistance_id
    assistor = assistance.assistor

    UserChannel.broadcast_to assistance.assistance_request.requestor, type: "AssistanceEnded"

    if assistor.teaching_assistances.currently_active.empty?
      ActionCable.server.broadcast "teachers", type:   "TeacherAvailable",
                                               object: UserSerializer.new(assistor).as_json
    end
    RequestQueue::BroadcastUpdate.call(program: Program.first)
  end

end
