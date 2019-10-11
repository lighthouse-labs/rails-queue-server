class RequestQueue::BroadcastTeacherBusy

  include Interactor

  before do
    @assistor = context.assistor
  end

  def call
    ActionCable.server.broadcast "teachers",  type:   "TeacherBusy",
                                              object: UserSerializer.new(@assistor).as_json
  end

end
