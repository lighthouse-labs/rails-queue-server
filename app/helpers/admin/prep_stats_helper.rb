module Admin::PrepStatsHelper

  # has the student completed all the milestone activities?
  def milestones_complete?(student, milestone_activities, milestone_count)
    student.activity_submissions.proper.where(activity_id: milestone_activities.select(:id)).count == milestone_count
  end

end
