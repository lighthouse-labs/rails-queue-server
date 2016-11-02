class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user
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

  def set_raven_context
    if current_user
      Raven.user_context({
        'id' => current_user.id,
        'email' => current_user.email
      })
    end
  end

  def current_user
    @current_user ||= User.find_by_auth_token(request.headers[:'x-auth-token']) if request.headers[:'x-auth-token'].present?
    @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
    cookies.signed[:user_id] = @current_user.id if @current_user && cookies.signed[:user_id].blank?

    @current_user
  end
  helper_method :current_user

  def teacher?
    current_user && current_user.is_a?(Teacher)
  end
  helper_method :teacher?

  def student?
    current_user && current_user.is_a?(Student)
  end
  helper_method :student?

  def active_student?
    student? && current_user.active_student?
  end
  helper_method :active_student?

  def alumni?
    student? && current_user.alumni?
  end
  helper_method :alumni?

  def admin?
    current_user.try :admin?
  end
  helper_method :admin?

  def can_tech_interview?
    admin? || current_user.try(:can_tech_interview?)
  end
  helper_method :can_tech_interview?

  def teachers_on_duty
    return [] if current_user && !current_user.is_a?(Teacher) && !current_user.is_a?(Student)

    if current_user
      location = current_user.location
      location = current_user.cohort.location if current_user.is_a?(Student)
      Teacher.where(on_duty: true, location: location)
    else
      []
    end
  end
  helper_method :teachers_on_duty

  def cohort
    return @cohort if @cohort
    # Teachers can switch to any cohort
    if teacher?
      @cohort ||= Cohort.find_by(id: session[:cohort_id]) if session[:cohort_id]
    end
    @cohort ||= current_user.try(:cohort) # Students have a cohort
    # Try to find the next one that's upcoming.
    # Failing that use the latest
    @cohort ||= (Cohort.upcoming.chronological.first || Cohort.most_recent.first)
    @program = @cohort.try(:program)
    @cohort
  end
  helper_method :cohort

  def cohorts
    @cohorts ||= Cohort.most_recent
  end
  helper_method :cohorts

  def dropdown_cohorts
    @dropdown_cohorts = cohorts.starts_between(3.months.ago.to_date, 2.weeks.from_now.to_date)
      .includes(location: [ :supported_by_location ])
      .group_by(&:location)
  end
  helper_method :dropdown_cohorts

  def streams
    @streams ||= Stream.order(:title)
  end
  helper_method :streams

  def preps
    @preps ||= Prep.all
  end
  helper_method :preps

  def pending_feedbacks
    current_user.feedbacks.pending.reverse_chronological_order.where.not(feedbackable: nil).not_expired
  end
  helper_method :pending_feedbacks

  def assign_as_student_to_cohort(cohort)
    current_user.cohort = cohort
    current_user.type = 'Student'
    current_user.save!
    flash[:notice] = "Welcome, you have student access to the cohort: #{cohort.name}!"
  end

  def apply_invitation_code(code)
    if ENV['TEACHER_INVITE_CODE'] == code
      make_teacher
    elsif cohort = Cohort.find_by(code: code)
      if admin?
        flash[:alert] = "This code is valid to register as a student for #{cohort.name}. You are an Admin so no change made for you."
      elsif teacher?
        flash[:alert] = "This code is valid to register as a student for #{cohort.name}. You are a teacher already so no change made for you."
      else
        assign_as_student_to_cohort(cohort)
      end
    else
      flash[:alert] = "Sorry, invalid code"
    end
  end

  def make_teacher
    unless teacher?
      current_user.type = 'Teacher'
      current_user.save!(validate: false)
      AdminMailer.new_teacher_joined(current_user).deliver
      flash[:notice] = "Welcome, you have teacher access!"
    end
  end

  def set_timezone
    if cohort && cohort.location
      # all locations are assumed to have timezone
      Time.zone = cohort.location.timezone
    end
  end

end
