class RequestQueue::CancelAssistance

  include Interactor

  before do
    @assistance = context.assistance
    @user       = context.user
  end

  def call
    context.fail! unless @assistance&.destroy
    BroadcastAssistanceCancelWorker.perform_async(@assistance.assistance_request.id, @assistance.assistor.id)
  end

end
