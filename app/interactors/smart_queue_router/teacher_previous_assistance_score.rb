class SmartQueueRouter::TeacherPreviousAssistanceScore

  include Interactor

  before do
    @teachers = context.teachers
    @requestor = context.assistance_request.requestor
  end

  def call
    puts 'prev assistance ++++++++++++++++++++++++++++++'

    @teachers.each do |_uid, teacher|
      assistances =  Assistance.using(:master).completed.assisted_by(teacher[:object]).requested_by(@requestor['uid'])
      break if assistances.empty?
      average_rating = assistances.where.not(rating: nil).average(:rating).to_f.round(2) || 2
      # Positive points for ratings >= 3 negative points for < 3
      rating_points = average_rating < 2 ? average_rating - 2 : average_rating - 1
      history_scale = assistances.count < 2 ? 1 : Math.log(assistances.count, 2)
      @teachers[teacher[:object].uid][:routing_score] ||= 0
      @teachers[teacher[:object].uid][:routing_score] += history_scale * rating_points * context.rating_multiplier
    end
  end

end
