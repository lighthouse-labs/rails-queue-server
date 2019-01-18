class RequestQueue::StartAssistance

  include Interactor

  before do
    @assistor = context.assistor
    @assistance_request = context.assistance_request
  end

  def call
    context.fail! unless @assistance_request.start_assistance(@assistor)
    BroadcastAssistanceStartWorker.perform_async(@assistance_request.id, @assistor.id)
  end

end
