class NationalQueue::BroadcastTeacherAvailability

  include Interactor

  before do
    @assistor = context.assistor
  end

  def call
    if @assistor&.busy?
      ActionCable.server.broadcast "teachers-national",  type:   "TeacherBusy",
                                                object: UserSerializer.new(@assistor).as_json
    elsif @assistor
      ActionCable.server.broadcast "teachers-national",  type:   "TeacherAvailable",
                                                object: UserSerializer.new(@assistor).as_json
    end
  end

end
