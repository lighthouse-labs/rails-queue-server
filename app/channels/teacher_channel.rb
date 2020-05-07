class TeacherChannel < ApplicationCable::Channel

  def subscribed
    stream_from channel_name
  end

  def on_duty(data)
    user = data['user_id'] ? User.find_by(id: data['user_id']) : current_user
    if user.is_a?(Teacher)
      NationalQueue::OnDuty.call(assistor: user)
      ActionCable.server.broadcast channel_name, type:   "TeacherOnDuty",
                                                 object: UserSerializer.new(user).as_json
    end
  end

  def off_duty(data)
    user = data['user_id'] ? User.find_by(id: data['user_id']) : current_user
    if user.is_a?(Teacher)
      NationalQueue::OffDuty.call(assistor: user)
      ActionCable.server.broadcast channel_name, type:   "TeacherOffDuty",
                                                 object: UserSerializer.new(user).as_json
    end
  end

  protected

  def channel_name
    "teachers-national"
  end

end
