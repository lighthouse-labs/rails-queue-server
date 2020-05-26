class SmartQueueRouter::GetOnDutyTeachers

  include Interactor

  def call
    users = []
    db_results = Octopus.using_group(:program_shards) do
      users += Teacher.on_duty
    end
    context.teachers = users.map { |v| [v.uid, { object: v, routing_score: 0 }] }.to_h || {}
  end

end
