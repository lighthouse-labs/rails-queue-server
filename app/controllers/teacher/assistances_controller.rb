class Teacher::AssistancesController < Teacher::BaseController

  def index
    @assistances = Assistance.where(assistor_id: current_user.id).order(created_at: :desc)
  end

end
