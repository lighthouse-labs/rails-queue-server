class RequestQueue::BroadcastNewQueuePositions

  include Interactor

  before do
    @location = context.location
  end

  def call
    Student.has_open_requests_in_location([@location]).each do |student|
      UserChannel.broadcast_to student, type: "QueuePositionUpdate", object: student.position_in_queue.as_json
    end
  end

end
