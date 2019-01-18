class RequestQueue::BroadcastTeacherAvailable

  include Interactor

  before do
    @assistor = context.assistor
  end

  def call
    if @assistor.teaching_assistances.currently_active.empty?
      ActionCable.server.broadcast "teachers", type:   "TeacherAvailable",
                                               object: UserSerializer.new(@assistor).as_json
    end
  end

end
