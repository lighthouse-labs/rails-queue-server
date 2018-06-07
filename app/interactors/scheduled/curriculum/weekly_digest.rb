class Scheduled::Curriculum::WeeklyDigest

  include Interactor

  before do
    @program = context.program
    @email = @program.curriculum_team_email
  end

  def call
    feedbacks = ActivityFeedback.last_seven_days.with_details.filter_by_ratings([1, 2, 3]).reverse_chronological_order.filter_by_program(@program.id).group_by(&:activity)
    AdminMailer.weekly_digest(feedbacks, @program, @email).deliver
  end

end
