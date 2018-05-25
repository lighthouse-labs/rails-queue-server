class WeeklyDigest

  include Interactor

  def call
    @feedbacks = ActivityFeedback.last_seven_days.where.not(detail: '').filter_by_ratings([1, 2, 3]).reverse_chronological_order.group_by(&:activity)
    AdminMailer.weekly_digest(@feedbacks).deliver
  end

end
