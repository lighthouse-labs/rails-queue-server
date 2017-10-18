class Admin::CurriculumBreaksController < Admin::BaseController

  before_action :require_cohort
  before_action :require_curriculum_break, only: [:edit, :update, :show]

  def index
    @curriculum_breaks = CurriculumBreak.for_cohort(@cohort)
  end

  def new
    @curriculum_break = CurriculumBreak.new(cohort: @cohort)
  end

  def show
  end

  def create
    @curriculum_break = CurriculumBreak.new(curriculum_break_params)
    if @curriculum_break.save
      redirect_to admin_cohort_curriculum_breaks_path(@cohort), notice: 'Created!'
    else
      render :new
    end
  end

  def update
    if @curriculum_break.update(curriculum_break_params)
      redirect_to admin_cohort_curriculum_breaks_path(@cohort), notice: 'Updated!'
    else
      render :edit
    end
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
