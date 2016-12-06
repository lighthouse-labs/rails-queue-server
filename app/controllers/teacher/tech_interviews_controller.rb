class Teacher::TechInterviewsController < Teacher::BaseController

  def index
    @tech_interviews = TechInterview.where(interviewer_id: current_user.id).order(created_at: :desc)
  end

end