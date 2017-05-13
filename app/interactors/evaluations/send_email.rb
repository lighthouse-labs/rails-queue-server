class Evaluations::SendEmail
  include Interactor

  before do
    @evaluation = context.evaluation
  end

  def call
    UserMailer.evaluation_result(@evaluation).deliver
  end

end