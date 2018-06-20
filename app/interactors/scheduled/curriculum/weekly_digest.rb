class Scheduled::Curriculum::WeeklyDigest

  include Interactor

  before do
    @program = context.program
  end

  def call
    # FIXME: We want to only look at feedback that is for activites in the given @program
    # However, activities don't have program_id (they should) and until then we cannot filter like this
    from = Date.current.advance(days: -7).beginning_of_day
    to = Date.yesterday.end_of_day
    context.feedbacks = ActivityFeedback.seven_days(from, to).with_details.filter_by_ratings([1, 2, 3]).reverse_chronological_order.group_by(&:activity)
    CurriculumTeamMailer.weekly_digest(context.feedbacks, @program).deliver
  end

end
