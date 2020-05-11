class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_action :authenticate_user
  before_action :set_raven_context

  private

  def authenticate_user
    if !current_user
      session[:attempted_url] = request.url
      render json: { message: 'Not Authenticated' }, status: :unauthorized
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
    # use JWT to auth user
    authHeader = request.headers["Authorization"]
    if authHeader.start_with?("Bearer ")
      token = authHeader[7..-1]
      decoded_token = JWT.decode token, ENV['TOKEN_SECRET'], true, { algorithm: 'HS256' }

      if decoded_token
        user_uid = decoded_token[0]['user_uid']
        compass_instance_id = decoded_token[0]['compass_instance_id']
        compass_instance = CompassInstance.using(:master).find_by(id: compass_instance_id)
        current_users = Octopus.using(compass_instance.name) do
          @current_user = User.find_by(uid: user_uid)
        end
      end

    end
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

  def alumni?
    student? && current_user.alumni?
  end
  helper_method :alumni?

  def admin?
    current_user.try :admin?
  end
  helper_method :admin?

  def all_teachers_on_duty
    return [] unless current_user && (current_user.is_a?(Teacher) || current_user.is_a?(Student))

    Teacher.where(on_duty: true)
  end
  helper_method :all_teachers_on_duty

  def pending_feedbacks
    @pending_feedbacks ||= current_user.feedbacks.pending.reverse_chronological_order.where.not(feedbackable: nil).not_expired
  end
  helper_method :pending_feedbacks

  def pending_feedbacks_count
    @pending_feedbacks_count ||= pending_feedbacks.count
  end
  helper_method :pending_feedbacks_count
end
