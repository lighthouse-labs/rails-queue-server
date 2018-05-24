class WeeklyDigest::Deploy

  include Interactor

  before do
    @feedbacks = context.feedbacks
  end

  def call
    AdminMailer.weekly_digest(@feedbacks).deliver
  end

end
