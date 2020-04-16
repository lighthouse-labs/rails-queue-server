class NationalQueue::BroadcastTeacherAvailability

  include Interactor

  before do
    @assistor = context.assistance_request.assistance&.assistor
  end

  def call
    NationalQueueChannel.broadcast "student-national-queue", type:   "TeacherUpdate",
                                              object: UserSerializer.new(@assistor).as_json if @assistor
  end

end
