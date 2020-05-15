class SmartQueueRouter::TeacherLocationScore

  include Interactor

  before do
    @teachers = context.teachers
    @same_location_bonus = context.same_location_bonus
    @requestor = context.assistance_request.requestor
  end

  def call
    puts 'location ++++++++++++++++++++++++++++++'

    @teachers.each do |_uid, teacher|
      teacher[:routing_score] ||= 0
      teacher[:routing_score] += @same_location_bonus if teacher[:object].location&.name == @requestor.dig('info', 'location')
    end
  end

end
