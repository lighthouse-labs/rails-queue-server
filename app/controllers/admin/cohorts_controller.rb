class Admin::CohortsController < Admin::BaseController

  before_action :require_cohort, only: [:edit, :update, :show]
  before_action :check_limited, only: [:show]

  def index
    @cohorts = Cohort.most_recent_first.all

    @cohort_location = current_user.location
    @cohort_location = @cohort_location.supported_by_location if @cohort_location.supported_by_location

    @active_cohorts = Cohort.is_active.where(location_id: @cohort_location)

    # exclude from @cohorts
    @cohorts = @cohorts.where.not(id: @active_cohorts.select(:id))
  end

  def new
    @cohort = Cohort.new(program: Program.first)
  end

  def edit
    @days = @cohort.disable_queue_days.join(',')
  end

  def create
    @cohort = Cohort.new(cohort_params)
    if @cohort.save
      redirect_to [:edit, :admin, @cohort], notice: 'Created!'
    else
      render :new
    end
  end

  def update
    handle_disable_queue_days
    if @cohort.update(cohort_params)
      redirect_to [:edit, :admin, @cohort], notice: 'Updated!'
    else
      render :edit
    end
  end

  def show
    @active_students = @cohort.students.active.includes(:location).references(:location).order('locations.name')
    @other_students  = @cohort.rolled_out_students.to_a + @cohort.students.deactivated.to_a
    @interview_templates = TechInterviewTemplate.all
    @projects = Project.all
  end

  private

  def handle_disable_queue_days
    if params['disable_queue_days']
      days_string = params['disable_queue_days'].gsub(/\s+/, "")
      days_arr = days_string.split(',').compact.first(100)
      @cohort.disable_queue_days = days_arr
    else
      @cohort.disable_queue_days = []
    end
  end

  def require_cohort
    @cohort = Cohort.find params[:id]
  end

  def check_limited
    redirect_to(admin_cohorts_path) if @cohort.limited?
  end

  def cohort_params
    params.require(:cohort).permit(
      :name,
      :start_date,
      :code,
      :program_id,
      :location_id,
      :teacher_email_group,
      :weekdays
    )
  end

end
