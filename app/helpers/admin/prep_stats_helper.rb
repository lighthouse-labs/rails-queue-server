module Admin::PrepStatsHelper

  def milestones_complete?(student)
    milestone_ids = @milestones.pluck(:id).sort
    complete_milestones = student.activity_submissions.pluck(:activity_id).sort & milestone_ids
    return complete_milestones === milestone_ids
  end

end
