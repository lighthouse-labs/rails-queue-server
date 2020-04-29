class SmartQueueRouter::GetOnDutyTeachers

  include Interactor

  def call
    context.teachers = Teacher.on_duty.map { |v| [v.id, { object: v, routing_score: 0 }] }.to_h || {}
  end

end
