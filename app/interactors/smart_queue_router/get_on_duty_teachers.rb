class SmartQueueRouter::GetOnDutyTeachers

  include Interactor

  def call
    context.teachers = Teacher.using(:web).on_duty.map { |v| [v.uid, { object: v, routing_score: 0 }] }.to_h || {}
  end

end
