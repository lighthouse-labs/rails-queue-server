class RequestQueue::RequestAssistance

  include Interactor

  before do
    @requestor   = context.requestor
    @reason      = context.reason
    @activity    = Activity.find_by id: context.activity_id if context.activity_id.present?
  end

  def call
    request = context.assistance_request = AssistanceRequest.new(
      requestor: @requestor,
      reason:    @reason,
      activity:  @activity
    )
    context.fail! unless request.save

    BroadcastAssistanceRequestWorker.perform_async(request.id)
  end

end
