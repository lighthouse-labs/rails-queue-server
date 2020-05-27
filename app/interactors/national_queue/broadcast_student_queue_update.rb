class NationalQueue::BroadcastStudentQueueUpdate

  include Interactor

  before do
    @assistance_request = context.assistance_request
  end

  def call
    unless @assistance_request.assistance&.end_at?
      AssistanceRequest.pending.each do |assistance_request|
        NationalQueueChannel.broadcast_to assistance_request.requestor, type: "requestUpdate", object: RequestSerializer.new(assistance_request).as_json
      end
    end
    NationalQueueChannel.broadcast_to @assistance_request.requestor, type: "requestUpdate", object: RequestSerializer.new(@assistance_request).as_json
  end

end
