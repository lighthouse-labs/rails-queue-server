class NationalQueue::BroadcastTeacherAvailability

  include Interactor

  before do
    @assistor = context.assistor
  end

  def call
    NationalQueueChannel.broadcast "student-national-queue", type:   "teacherUpdate",
                                              object: UserSerializer.new(@assistor).as_json if @assistor
  end

end
