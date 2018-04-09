class UserChannel < ApplicationCable::Channel

  def subscribed
    stream_for current_user

    UserChannel.broadcast_to current_user, type: "UserConnected", object: UserSerializer.new(current_user).as_json
  end

  def request_assistance(data)
    ar = AssistanceRequest.new(
      requestor:   current_user,
      reason:      data["reason"],
      activity_id: data["activity_id"]
    )
    ar.save

    location_name = Location.find(ar.assistor_location_id).name || 'Vancouver'
    ActionCable.server.broadcast "assistance-#{location_name}", type:   "AssistanceRequest",
                                                                object: AssistanceRequestSerializer.new(ar, root: false).as_json

    UserChannel.broadcast_to current_user, type:   "AssistanceRequested",
                                           object: current_user.position_in_queue
  end

  def cancel_assistance
    ar = current_user.assistance_requests.where(type: nil).open_or_in_progress_requests.newest_requests_first.first
    if ar && ar.cancel
      location_name = Location.find(ar.assistor_location_id).name || 'Vancouver'
      ActionCable.server.broadcast "assistance-#{location_name}", type:   "CancelAssistanceRequest",
                                                                  object: AssistanceRequestSerializer.new(ar, root: false).as_json

      UserChannel.broadcast_to current_user, type: "AssistanceEnded"

      teacher_available(ar.assistance.assistor) if ar.assistance
      update_students_in_queue(ar.requestor.cohort.location.name)
    end
  end

end
