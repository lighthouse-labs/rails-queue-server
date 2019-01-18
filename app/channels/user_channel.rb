class UserChannel < ApplicationCable::Channel

  def subscribed
    stream_for current_user

    UserChannel.broadcast_to current_user, type:   "UserConnected",
                                           object: UserSerializer.new(current_user).as_json
  end

  def request_assistance(data)
    RequestQueue::RequestAssistance.call(
      requestor:   current_user,
      reason:      data["reason"],
      activity_id: data["activity_id"]
    )
  end

  def cancel_assistance
    RequestQueue::CancelRequest.call(
      requestor: current_user
    )
  end

end
