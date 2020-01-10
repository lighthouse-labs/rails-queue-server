class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user
  before_action :registration_check
  before_action :set_timezone
  before_action :set_raven_context

  private

  def authenticate_user
    if !current_user
      session[:attempted_url] = request.url
      redirect_to new_session_path, alert: 'Please login first!'
    elsif current_user.deactivated?
      session[:user_id] = nil
      redirect_to :root, alert: 'Your account has been deactivated. Please contact the admin if this is in error.'
    end
  end

  def registration_check
    if current_user && !current_user.completed_registration?
      redirect_to edit_profile_path, alert: 'Please complete your profile'
    end
  end

  def admin_required
    unless admin?
      flash[:alert] = 'Access Not Allowed'
      redirect_to :root
    end
  end

  def set_raven_context
    if current_user
      Raven.user_context('id'    => current_user.id,
                         'email' => current_user.email)
    end
  end

  def current_user
    @current_user ||= User.find_by(auth_token: request.headers[:'x-auth-token']) if request.headers[:'x-auth-token'].present?
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    cookies.signed[:user_id] = @current_user.id if @current_user && cookies.signed[:user_id].blank?

    @current_user
  end
  helper_method :current_user

  def teacher?
    current_user&.is_a?(Teacher)
  end
  helper_method :teacher?

  def student?
    current_user&.is_a?(Student)
  end
  helper_method :student?

  def active_student?
    student? && current_user.active_student?
  end
  helper_method :active_student?

  def student_with_queue?
    active_student? && current_user.cohort.active_queue?
  end
  helper_method :student_with_queue?

  def prep_assistance?
    @program&.prep_assistance? && current_user&.enrolled_and_prepping?
  end
  helper_method :prep_assistance?

  def url_for_prep_assistance
    current_user&.enrolled_and_prepping? && @program&.prep_assistance_url
  end
  helper_method :url_for_prep_assistance

  def alumni?
    student? && current_user.alumni?
  end
  helper_method :alumni?

  def admin?
    current_user.try :admin?
  end
  helper_method :admin?

  def impersonating?
    session[:impersonating_user_id].present?
  end
  helper_method :impersonating?

  def teachers_on_duty
    return [] unless current_user && (current_user.is_a?(Teacher) || current_user.is_a?(Student))

    using_cohort_location = current_user.is_a?(Student) && !current_user.cohort.local_assistance_queue?

    location = using_cohort_location ?
      current_user.cohort.location : current_user.location

    Teacher.where(on_duty: true, location: location)
  end
  helper_method :teachers_on_duty

  def cohort
    if impersonating?
      @cohort = Cohort.find_by(id: session[:cohort_id])
      @program = @cohort.try(:program)
    end

    return @cohort if @cohort
    # Teachers can switch to any cohort
    if teacher?
      @cohort ||= Cohort.find_by(id: session[:cohort_id]) if session[:cohort_id]
    end
    @cohort ||= current_user.try(:cohort) # Students have a cohort
    # Try to find the next one that's upcoming.
    # Failing that use the latest
    @cohort ||= (Cohort.upcoming.chronological.first || Cohort.most_recent_first.first)
    @program = @cohort.try(:program)
    @cohort
  end
  helper_method :cohort

  def cohorts
    @cohorts ||= Cohort.most_recent_first
  end
  helper_method :cohorts

  def dropdown_cohorts
    @dropdown_cohorts = cohorts.starts_between(3.months.ago.to_date, 2.weeks.from_now.to_date)
                               .includes(:location)
                               .group_by(&:location)
  end
  helper_method :dropdown_cohorts

  def streams
    @streams ||= Stream.order(:title)
  end
  helper_method :streams

  def preps
    @preps ||= Prep.active.all
  end
  helper_method :preps

  def available_workbooks
    @available_workbooks ||= Workbook.available_to(current_user)
  end
  helper_method :available_workbooks

  def teacher_resources
    @teacher_resources ||= TeacherSection.active.all
  end
  helper_method :teacher_resources

  def pending_feedbacks
    @pending_feedbacks ||= current_user.feedbacks.pending.reverse_chronological_order.where.not(feedbackable: nil).not_expired
  end
  helper_method :pending_feedbacks

  def pending_feedbacks_count
    @pending_feedbacks_count ||= pending_feedbacks.count
  end
  helper_method :pending_feedbacks_count

  def apply_invitation_code(code)
    if cohort = Cohort.find_by(code: code)
      if admin?
        flash[:alert] = "This code is valid to register as a student for #{cohort.name}. You are an Admin so no change made for you."
      elsif teacher?
        flash[:alert] = "This code is valid to register as a student for #{cohort.name}. You are a teacher already so no change made for you."
      else
        response = AssignAsStudentToCohort.call(cohort: cohort, user: current_user)
        if response.success?
          flash[:notice] = "Welcome, you have student access to the cohort: #{cohort.name}!"
        else
          flash[:alert] = response.error
        end
      end
    elsif program = Program.find_by(teacher_invite_code: code)
      make_teacher(program)
    else
      flash[:alert] = "Sorry, invalid code"
    end
  end

  # In the future this will be a role, and we will use `program` to create the role - KV
  def make_teacher(_program = nil)
    unless teacher?
      current_user.type = 'Teacher'
      current_user.save!(validate: false)
      AdminMailer.new_teacher_joined(current_user).deliver
      flash[:notice] = "Welcome, you have teacher access!"
    end
  end

  def set_timezone
    if cohort&.location
      # all locations are assumed to have timezone
      Time.zone = cohort.location.timezone
    end
  end

end
