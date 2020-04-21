class SmartQueueRouter::TeacherPreviousAssistanceScore

  include Interactor

  before do
    @teachers = context.teachers
    @assistee = context.assistance_request.requestor
  end

  def call
    teachers_with_history = Teacher.on_duty.has_assisted_student(@assistee)
    teachers_with_history.each do |teacher|
      assistances = teacher.teaching_assistances.completed.assisting(@assistee)
      if assistances.count > 0
        average_rating = assistances.where.not(rating: nil).average(:rating).to_f.round(2) || 3
        # Positive points for ratings >= 3 negative points for < 3
        rating_points = average_rating < 3 ? average_rating - 3 : average_rating - 2
        @teachers[teacher.id][:routing_score]  += Math.log(assistances.count, 2) * rating_points * context.rating_multiplier
      end
    end

    puts 'pervious assist~~~~~~~~~~~~~~~~~~~'
    puts @teachers.inspect
    puts '~~~~~~~~~~~~~~~~~~~'       
  end
end
