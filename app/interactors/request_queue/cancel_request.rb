class RequestQueue::CancelRequest

  include Interactor

  before do
    @requestor = context.requestor
  end

  def call
    @assistance_request = context.assistance_request = @requestor.assistance_requests.where(type: nil).open_or_in_progress_requests.newest_requests_first.first
    BroadcastRequestCancellationWorker.perform_async(@assistance_request)
  end

end
