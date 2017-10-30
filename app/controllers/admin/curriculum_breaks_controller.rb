class Admin::CurriculumBreaksController < Admin::BaseController

  before_action :require_cohort
  before_action :require_curriculum_break, only: [:edit, :update, :destroy, :show]

  def new
    @curriculum_break = CurriculumBreak.new(cohort: @cohort)
  end

  def edit; end

  def create
    @curriculum_break = CurriculumBreak.new(curriculum_break_params)
    @curriculum_break.cohort = @cohort
    if @curriculum_break.save
      redirect_to edit_admin_cohort_path(@cohort), notice: 'Created a cohort break!'
    else
      render :new
    end
  end

  def destroy
    if @curriculum_break.destroy
      redirect_to edit_admin_cohort_path(@cohort), notice: 'Deleted a cohort break!'
    else
      redirect_to edit_admin_cohort_path(@cohort), alert: "Couldn't do it!"
    end
  end

  def update
    if @curriculum_break.update(curriculum_break_params)
      redirect_to edit_admin_cohort_path(@cohort), notice: 'Updated cohort break!'
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
      :reason,
      :starts_on,
      :num_weeks
    )
  end

end
