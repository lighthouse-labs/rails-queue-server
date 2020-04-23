class NationalQueueChannel < ApplicationCable::UpdateChannel

  @@updates_type = 'queueUpdate'
  @@max_updates_length = 10

  def subscribed
    stream_for current_user
    stream_from 'student-national-queue'
    stream_from 'teacher-national-queue' if current_user&.is_a?(Teacher)
    stream_from 'admin-national-queue' if current_user&.admin?
  end

  def assistance_request_state
    NationalQueueChannel.broadcast_to current_user, type:   "requestUpdate",
    object: NationalQueueAssistanceRequestSerializer.new(current_user.assistance_requests.newest_requests_first.first).as_json
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
      options:   {
        type:       'cancel',
        request_id: data["request_id"]
      }
    )
  end

  def cancel_assistance(data)
    NationalQueue::UpdateRequest.call(
      assistor: current_user,
      options:  {
        type:       'cancel_assistance',
        request_id: data["request_id"]
      }
    )
  end

  def start_assisting(data)
    NationalQueue::UpdateRequest.call(
      assistor: current_user,
      options:  {
        type:       'start_assistance',
        request_id: data["request_id"]
      }
    )
  end

  def finish_assistance(data)
    NationalQueue::UpdateRequest.call(
      assistor: current_user,
      options:  {
        type:       'finish_assistance',
        request_id: data["request_id"],
        note:       data["notes"],
        notify:     data["notify"],
        rating:     data["rating"]
      }
    )
  end

  def start_evaluating(data)
    NationalQueue::UpdateEvaluation.call(
      assistor: current_user,
      options:  {
        type:          'start_evaluating',
        evaluation_id: data["evaluation_id"]
      }
    )
  end

  def cancel_evaluating(data)
    NationalQueue::UpdateEvaluation.call(
      assistor: current_user,
      options:  {
        type:          'cancel_evaluating',
        evaluation_id: data["evaluation_id"]
      }
    )
  end

  def cancel_interview(data)
    NationalQueue::UpdateTechInterview.call(
      assistor: current_user,
      options:  {
        type:              'cancel_interview',
        tech_interview_id: data["tech_interview_id"]
      }
    )
  end

end
