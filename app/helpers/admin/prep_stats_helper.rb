module Admin::PrepStatsHelper

  def milestones_complete?(student, milestone_ids)
    complete_milestones = student.activity_submissions.proper.order(activity_id: :asc).pluck(:activity_id).uniq & milestone_ids
    return complete_milestones === milestone_ids
  end

end
