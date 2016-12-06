class Teacher::EvaluationsController < Teacher::BaseController

  def index
    @evaluations = Evaluation.where(teacher_id: current_user.id).order(created_at: :desc)
  end

end