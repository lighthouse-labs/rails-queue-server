class Evaluations::CreateFeedbackStub

  include Interactor

  before do
    @evaluation = context.evaluation
  end

  def call
    student = @evaluation.student
    teacher = @evaluation.teacher
    Feedback.create(student: student, teacher: teacher, feedbackable: @evaluation)
  end

end
