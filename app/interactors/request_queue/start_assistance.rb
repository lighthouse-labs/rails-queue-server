class RequestQueue::StartAssistance

  include Interactor

  before do
    @assistor = context.assistor
    @assistance_request = context.assistance_request
  end

  def call
    assistance = @assistance_request.start_assistance(@assistor)
    context.fail! unless assistance
    BroadcastAssistanceStartWorker.perform_async(@assistance_request.id, @assistor.id, assistance&.conference_link)
  end

end
