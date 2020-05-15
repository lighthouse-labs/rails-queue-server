class NationalQueue::CreateAssistanceRequest

  include Interactor

  before do
    @requestor   = context.requestor
    @request     = context.request
  end

  def call
    compass_instance = CompassInstance.find_by(id: @requestor['compass_instance_id'])
    ar = context.assistance_request = AssistanceRequest.new(
      requestor: @requestor,
      request: @reason,
      compass_instance: compass_instance,
      type: 'UserRequest'
    )
    context.fail!(error: "Could not save AR") unless ar.save!
  end

  def rollback
    context.assistance_request.cancel
  end

end
