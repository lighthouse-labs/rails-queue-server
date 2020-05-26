class SmartQueueRouter::TeacherLocationScore

  include Interactor

  before do
    @teachers = context.teachers
    @same_location_weight = context.same_location_weight
    @requestor = context.assistance_request.requestor
  end

  def call
    puts 'location ++++++++++++++++++++++++++++++'

    @teachers.each do |_uid, teacher|
      score = teacher[:object].location&.name == @requestor.dig('info', 'location') ? 1 * @same_location_weight : 0
      teacher[:routing_score].total += score
      teacher[:routing_score].summary['TeacherLocationScore'] = score
    end
  end

end
