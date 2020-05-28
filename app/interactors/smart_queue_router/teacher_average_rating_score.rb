class SmartQueueRouter::TeacherAverageRatingScore

  include Interactor

  before do
    @teachers = context.teachers
    @requestor = context.assistance_request.requestor
    @avg_rating_weight = context.avg_rating_weight
  end

  def call
    @teachers.each do |_uid, teacher|
      assistances = Assistance.completed.assisted_by(teacher[:object])
      break if assistances.empty?

      average_rating = assistances.average_feedback_rating.to_f.round(2) || 2
      score = normalize(average_rating) * @avg_rating_weight
      teacher[:routing_score].total += score
      teacher[:routing_score].summary['TeacherAverageRatingScore'] = score
    end
  end

  private

  def normalize(rating)
    # -1 for 1 star up to +1 for 5 star
    (rating - 2) / 2
  end

end
