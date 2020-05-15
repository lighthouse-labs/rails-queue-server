class NationalQueue::BroadcastTeacherAvailability

  include Interactor

  before do
    @assistor = context.assistor
  end

  def call
    puts '+broadcast teacher availabiity++++++++++++++++++++++='
    if @assistor&.busy?
      NationalQueueChannel.broadcast "student-national-queue", type:   "teacherUpdate",
                                                               object: UserSerializer.new(@assistor).as_json
    elsif @assistor
      NationalQueueChannel.broadcast "student-national-queue",  type:   "teacherUpdate",
                                                                object: UserSerializer.new(@assistor).as_json
    end
  end

end
