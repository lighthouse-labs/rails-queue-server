class TeacherChannel < ApplicationCable::Channel

  def subscribed
    stream_from channel_name
  end

  def on_duty
    if current_user.is_a?(Teacher)
      NationalQueue::OnDuty.call( assistor: current_user)
      ActionCable.server.broadcast channel_name, type:   "TeacherOnDuty",
                                                 object: UserSerializer.new(current_user).as_json
    end
  end

  def off_duty
    if current_user.is_a?(Teacher)
      NationalQueue::OffDuty.call( assistor: current_user)
      ActionCable.server.broadcast channel_name, type:   "TeacherOffDuty",
                                                 object: UserSerializer.new(current_user).as_json
    end
  end

  protected

  def channel_name
    "teachers-national"
  end

end
