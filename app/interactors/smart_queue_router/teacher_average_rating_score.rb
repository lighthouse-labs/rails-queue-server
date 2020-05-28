class SmartQueueRouter::TeacherAverageRatingScore

  include Interactor

  before do
    @teachers = context.teachers
    @requestor = context.assistance_request.requestor
    @avg_rating_weight = context.avg_rating_weight
  end

  def call
    @teachers.each do |_uid, teacher|
      average_rating = Assistance.completed.assisted_by(teacher[:object])&.joins(:feedback).average("feedbacks.rating")&.to_f&.round(2) || 2
      break unless average_rating

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
