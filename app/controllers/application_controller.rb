class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_action :authenticate_user
  before_action :set_raven_context

  private

  def authenticate_user
    unless current_user
      session[:attempted_url] = request.url
      render json: { message: 'Not Authenticated' }, status: :unauthorized
    end
  end

  def super_admin_required
    render json: { error: 'Not Allowed.' } unless @current_user['access'].include?("super_admin")
  end

  def admin_required
    render json: { error: 'Not Allowed.' } unless @current_user['access'].include?("admin")
  end

  def set_raven_context
    if current_user
      Raven.user_context('id'    => current_user['uid'],
                         'email' => current_user['fullName'])
    end
  end

  def current_user
    # use JWT to auth user
    authHeader = request.headers["Authorization"]
    if authHeader&.start_with?("Bearer ")
      token = authHeader[7..-1]
      decoded_token = JWT.decode token, ENV['TOKEN_SECRET'], true, { algorithm: 'HS256' }

      if decoded_token
        user_uid = decoded_token[0]['uid']
        @current_user = decoded_token[0]
      end

    end
  end
  helper_method :current_user

  def all_compass_instance_results
    users = []
    Octopus.using_group(:program_shards) do
      users += yield
    end
    users
  end

  def first_compass_instance_result
    Octopus.using_group(:program_shards) do
      users =  yield
      return users if users.present?
    end
  end

end
