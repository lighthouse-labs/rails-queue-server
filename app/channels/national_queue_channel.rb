class NationalQueueChannel < ApplicationCable::UpdateChannel

  @@updates_type = 'queueUpdate'
  @@public_channel = 'teacher-national-queue'
  @@max_updates_length = 10

  def subscribed
    stream_from current_user['uid']
    stream_from 'student-national-queue'
    stream_from 'teacher-national-queue' if current_user['access'].include?('teacher')
    stream_from 'admin-national-queue' if current_user['access'].include?('admin')
  end

  def assistance_request_state
    NationalQueueChannel.broadcast_to current_user, type:   "requestUpdate",
                                                    object: RequestSerializer.new(UserRequest.requested_by(current_user['uid']).pending_or_in_progress.first).as_json
    NationalQueueChannel.broadcast_to current_user, type:   "feedbackUpdate",
                                                    object: Assistance.requested_by(current_user['uid']).without_feedback.count
  end

  def request_assistance(data)
    result = NationalQueue::RequestAssistance.call(
      requestor:    current_user,
      request:      data["request"],
      request_type: 'UserRequest'
    )
    puts(result.errors) unless result.success?
  end

  def cancel_assistance_request(data)
    result = NationalQueue::UpdateRequest.call(
      requestor: current_user,
      options:   {
        type:       'cancel',
        request_id: data["request_id"]
      }
    )
    puts(result.errors) unless result.success?
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
        notes:      data["notes"],
        notify:     data["notify"],
        rating:     data["rating"]
      }
    )
  end

  def provide_assistance(data)
    NationalQueue::ProvideAssistance.call(
      assistor:     current_user,
      requestor:    data["requestor"],
      request_type: 'ManualRequest',
      options:      {
        note:   data["notes"],
        notify: data["notify"],
        rating: data["rating"]
      }
    )
  end

  def provide_feedback(data)
    NationalQueue::ProvideFeedback.call(
      requestor: current_user,
      task_id:   data["task_id"],
      notes:     data["notes"],
      rating:    data["rating"]
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
      interviewer: current_user,
      options:     {
        type:              'cancel_interview',
        tech_interview_id: data["tech_interview_id"]
      }
    )
  end

  def toggle_duty(data)
    if data["user_uid"] == current_user["uid"] || current_user['access'].include?("admin")
      result = NationalQueue::ToggleDuty.call(
        user_uid: data["user_uid"]
      )
      puts(result.errors) unless result.success?
    end
  end

end
