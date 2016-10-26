class Admin::RolloversController < Admin::BaseController

  before_action :require_student

  # ajax GET (for modal)
  def new
    @cohorts = Cohort.active_or_upcoming.
      where(location_id: @student.cohort.location_id).
      where.not(id: @student.cohort_id).chronological.
      where('cohorts.start_date > ?', @student.cohort.start_date)

    render 'new', layout: false
  end

  # regular POST from modal
  def create
    @cohort = Cohort.active_or_upcoming.find params[:cohort_id]
    @student.initial_cohort ||= @student.cohort
    @student.cohort = @cohort
    if @student.save
      redirect_to :back, notice: 'Student rolled over'
    else
      redirect_to :back, alert: "Could not roll over: #{@student.errors.full_messages.first}"
    end
  end


  private

  def require_student
    @student = Student.find params[:student_id]
  end

end
