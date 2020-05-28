class NationalQueue::CreateAssistance

  include Interactor

  before do
    @requestor    = context.requestor
    @assistor     = context.assistor
    @options      = context.options
    @request_type = context.request_type
  end

  def call
    context.fail! unless @requestor
    compass_instance = @compass_instance
    compass_instance ||= CompassInstance.find_by(id: @requestor['compass_instance_id'])
    compass_instance ||= CompassInstance.find_by(id: @assistor['compass_instance_id'])
    assistance_request = AssistanceRequest.new(
      requestor:        @requestor,
      compass_instance: compass_instance,
      type:             @request_type
    )
    context.fail! unless assistance_request.save
    task = assistance_request.assign_task(@assistor)
    assistance_request.start_assistance(@assistor)
    assistance = assistance_request.reload.assistance
    assistance.end(@options[:note], @options[:notify], @options[:rating])
    context.assistance_request = assistance_request
    context.updates ||= []
    context.updates.push({ task: task, shared: true })
  end

  def rollback
    context.assistance_request.cancel
  end

end
