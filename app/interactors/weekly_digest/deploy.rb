class WeeklyDigest::Deploy

  include Interactor

  before do
    @feedbacks = Feedback.limit(2) # temporary placeholder data
  end

  def call
    AdminMailer.weekly_digest(@feedbacks).deliver
  end

end
