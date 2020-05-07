class NationalQueue::CreateAssistance

  include Interactor

  before do
    @requestor   = User.find_by id: context.requestor_id
    @assistor    = context.assistor
    @options     = context.options
  end

  def call
    context.fail! unless @requestor
    assistance_request = AssistanceRequest.new(requestor: @requestor, reason: "Offline assistance requested")
    context.fail! unless assistance_request.save
    assistance_request.start_assistance(@assistor)
    assistance = assistance_request.reload.assistance
    assistance.end(@options[:note], @options[:notify], @options[:rating])
    context.assistance_request = assistance_request
    context.updates ||= []
    context.updates.push({ task: assistance_request, shared: true })
  end

  def rollback
    context.assistance_request.cancel
  end

end
