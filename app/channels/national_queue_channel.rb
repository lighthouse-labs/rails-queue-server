class NationalQueueChannel < ApplicationCable::Channel
  @@message_sequence ||= 0
  
  def self.broadcast_to(model, message)
    # add sequence number and store messages
    message[:sequence] = @@message_sequence += 1
    super(model, message)
  end

  def self.broadcast(broadcasting, message)
    # add sequence number and store messages
    message[:sequence] = @@message_sequence += 1
    ActionCable.server.broadcast broadcasting , message
  end

  def subscribed
    stream_for current_user
    NationalQueueChannel.broadcast_to current_user, type:   "requestUpdate",
                                           object: NationalQueueAssistanceRequestSerializer.new(current_user.assistance_requests.newest_requests_first.first).as_json
    stream_from 'student-national-queue'
    if current_user&.is_a?(Teacher)
      stream_from 'teacher-national-queue'
    end
    @update_sequence = 0;
  end

  def unsubscribed
    # cleanup
  end

  def request_assistance(data)
    NationalQueue::RequestAssistance.call(
      requestor:   current_user,
      reason:      data["reason"],
      activity_id: data["activity_id"]
    )
  end

  def cancel_assistance_request(data)
    NationalQueue::UpdateRequest.call(
      requestor: current_user,
      options: {
        type: 'cancel',
        request_id: data["request_id"]
      }
    )
  end

  def cancel_assistance(data)
    NationalQueue::UpdateRequest.call(
      requestor: current_user,
      options: {
        type: 'cancel_assistance',
        request_id: data["request_id"]
      }
    )
  end

  def start_assisting(data)
    NationalQueue::UpdateRequest.call(
      assistor: current_user,
      options: {
        type: 'start_assistance',
        request_id: data["request_id"],
      }
    )
  end

  def finish_assistance(data)
    NationalQueue::UpdateRequest.call(
      assistor: current_user,
      options: {
        type: 'finish_assistance',
        request_id: data["request_id"],
        note: data["notes"],
        notify: data["notify"],
        rating: data["rating"]
      }
    )
  end

  def start_evaluating(data)
    NationalQueue::UpdateEvaluation.call(
      assistor: current_user,
      options: {
        type: 'start_evaluating',
        evaluation_id: data["evaluation_id"]
      }
    )
  end

  def cancel_evaluating(data)
    NationalQueue::UpdateEvaluation.call(
      assistor: current_user,
      options: {
        type: 'cancel_evaluating',
        evaluation_id: data["evaluation_id"]
      }
    )
  end

  def cancel_interviewing(data)
    interview = TechInterview.find_by id: data["interview_id"]
    StopTechInterview.call(
      tech_interview: interview,
      user:           current_user
    )
  end

end
