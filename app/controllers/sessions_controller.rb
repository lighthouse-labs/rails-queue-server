class SessionsController < ApplicationController

  skip_before_action :authenticate_user, only: [:new, :create]
  before_action :admin_required, only: [:impersonate]

  def new
    redirect_to day_path('today') if current_user
  end

  def create
    @current_user = User.authenticate_via_github auth_hash_params
    session[:user_id] = @current_user.id
    cookies.signed[:user_id] = @current_user.id
    if @current_user.completed_registration?
      if session[:invitation_code]
        apply_invitation_code(session[:invitation_code])
        session[:invitation_code] = nil
      end
      # Ok they are ready to go and fully registered
      if destination_url = session[:attempted_url]
        session[:attempted_url] = nil
        redirect_to destination_url
      else
        redirect_to :root
      end
    else
      redirect_to [:edit, :profile]
    end
  end

  def destroy
    reset_session
    cookies.delete :user_id
    redirect_to :root
  end

  def revert_admin
    if impersonating?
      session[:user_id] = session[:impersonating_user_id]
      session[:impersonating_user_id] = nil
      redirect_to admin_users_path
    end
  end

  def impersonate
    impersonated_user = User.find(params[:id])
    if impersonated_user.admin?
      flash[:alert] = 'You cannot impersonate an admin'
      return redirect_to admin_users_path
    elsif impersonated_user.is_a?(Student)
      session[:cohort_id] = impersonated_user.cohort.id
    end
    session[:user_id] = impersonated_user.id
    session[:impersonating_user_id] = current_user.id
    redirect_to day_path('today')
  end

  protected

  def auth_hash_params
    request.env['omniauth.auth']
  end

end
