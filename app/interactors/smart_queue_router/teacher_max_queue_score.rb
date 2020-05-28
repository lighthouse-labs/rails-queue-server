class SmartQueueRouter::TeacherMaxQueueScore

  include Interactor

  before do
    @teachers = context.teachers
    @max_queue_size = context.max_queue_size
    @max_queue_weight = context.max_queue_weight
  end

  def call
    @teachers.each do |_uid, teacher|
      next unless teacher[:object].queue_tasks.pending.count > @max_queue_size

      score = -1 * @max_queue_weight
      teacher[:routing_score].summary['TeacherMaxQueueScore'] = score
      teacher[:routing_score].total += score
    end
  end

end
