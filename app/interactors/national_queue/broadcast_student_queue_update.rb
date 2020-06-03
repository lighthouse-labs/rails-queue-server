class NationalQueue::BroadcastStudentQueueUpdate

  include Interactor

  before do
    @assistance_request = context.assistance_request
  end

  def call
    # Send user request updates to student to update request button
    if @assistance_request.is_a? UserRequest
      unless @assistance_request.assistance&.end_at?
        UserRequest.pending.each do |assistance_request|
          NationalQueueChannel.broadcast_to assistance_request.requestor, type: "requestUpdate", object: RequestSerializer.new(assistance_request).as_json
        end
      end
      NationalQueueChannel.broadcast_to @assistance_request.requestor, type: "requestUpdate", object: RequestSerializer.new(@assistance_request).as_json
    end
  end

end
