class Scheduled::Curriculum::WeeklyDigest

  include Interactor

  before do
    @program = context.program
  end

  def call
    # FIXME: We want to only look at feedback that is for activites in the given @program
    # However, activities don't have program_id (they should) and until then we cannot filter like this
    context.feedbacks = ActivityFeedback.last_seven_days.with_details.filter_by_ratings([1, 2, 3]).reverse_chronological_order.group_by(&:activity)
    CurriculumTeamMailer.weekly_digest(context.feedbacks, @program).deliver
  end

end
