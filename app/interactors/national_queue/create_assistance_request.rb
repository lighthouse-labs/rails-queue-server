class NationalQueue::CreateAssistanceRequest

  include Interactor

  before do
    @requestor   = context.requestor
    @request     = context.request
    @assistor    = context.assistor 
    @type        = context.type
    @compass_instance = context.compass_instance
  end

  def call
    compass_instance = @compass_instance || CompassInstance.find_by(id: @requestor['compass_instance_id'])
    ar = context.assistance_request = AssistanceRequest.new(
      requestor: @requestor,
      request: @request,
      compass_instance: compass_instance,
      type: @type
    )
    context.fail!(error: "Could not save AR") unless ar.save!
    ar.start_assistance(@assistor) if @assistor
  end

  def rollback
    context.assistance_request.cancel
  end

end
