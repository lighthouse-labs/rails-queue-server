class NationalQueue::UpdateAssistanceRequest

  include Interactor

  before do
    @assistance_request = context.options[:request_id] ? AssistanceRequest.find_by(id: context.options[:request_id]) : context.requestor&.assistance_requests&.open_or_in_progress_requests.first
    @options = context.options
    @assistor = context.assistor
  end

  def call
    context.fail! unless @assistance_request
    context.assistor = @assistance_request.assistance&.assistor
    case @options[:type]
    when 'start_assistance'
      success = @assistance_request.start_assistance(@assistor)
    when 'cancel'
      success = @assistance_request.cancel
    when "end_assistance"
      success = @assistance_request.end_assistance
    when 'cancel_assistance'
      success = @assistance_request.cancel_assistance
    when 'finish_assistance'
      success = @assistance_request.assistance.end(@options[:notes], @options[:notify], @options[:rating])
    end
    context.fail! unless success
    context.assistor ||= @assistance_request.assistance&.assistor
    context.assistance_request = @assistance_request
  end

end
