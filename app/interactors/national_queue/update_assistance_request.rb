class RequestQueue::CancelRequest

  include Interactor

  before do
    # @assistance_request = context.assistance_request
    @options = context.options
  end

  def call
    ar = AssistanceRequest.find_by id: @options[:request_id]
    case @options[:type]
    when 'start_assistance'
      success = ar.start_assistance(@options[:assistor])
    when 'cancel'
      success = ar.cancel
    when "end_assistance"
      success = ar.end_assistance
    when 'cancel_assistance'
      success = ar.cancel_assistance
    end
    context.fail! unless success
    context.assistance_request = ar
  end
end
