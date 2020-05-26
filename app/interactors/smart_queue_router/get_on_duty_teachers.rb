class SmartQueueRouter::GetOnDutyTeachers

  include Interactor
  
  before do
    @assistance_request = context.assistance_request
  end

  def call
    users = []
    db_results = Octopus.using_group(:program_shards) do
      users += Teacher.on_duty
    end
    teachers = users.map do |teacher| 
      [teacher.uid, { object: teacher, routing_score: RoutingScore.new(assistance_request: @assistance_request, assistor_uid: teacher.uid, total: 0, summary: {}) }]
    end
    context.teachers = teachers.to_h || {}
  end

end
