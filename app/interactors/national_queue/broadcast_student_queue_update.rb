class NationalQueue::BroadcastStudentQueueUpdate

  include Interactor

  before do
    @assistance_request = context.assistance_request
  end

  def call
    if @assistance_request.in_progress?
      Student.has_open_requests.each do |student|
        NationalQueueChannel.broadcast_to student, type: "requestUpdate", object: NationalQueueAssistanceRequestSerializer.new(student.assistance_requests.open_or_in_progress_requests.first).as_json
      end
    end
    NationalQueueChannel.broadcast_to @assistance_request.requestor, type: "requestUpdate", object: NationalQueueAssistanceRequestSerializer.new(@assistance_request).as_json
  end

end
