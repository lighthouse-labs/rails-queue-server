class Admin::CurriculumBreaksController < Admin::BaseController

  before_action :require_cohort
  before_action :require_curriculum_break, only: [:edit, :update, :show]

  def index
  end

  def new
  end

  def show
  end

  private

  def require_cohort
    @cohort = Cohort.find params[:cohort_id]
  end

  def require_curriculum_break
    @curriculum_break = CurriculumBreak.find params[:id]
  end

  def curriculum_break_params
    params.require(:curriculum_break).permit(
      :name,
      :starts_on,
      :num_weeks,
      :cohort_id
    )
  end


end
