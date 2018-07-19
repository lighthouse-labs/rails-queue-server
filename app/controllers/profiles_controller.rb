class ProfilesController < ApplicationController

  before_action :load_user, only: [:edit, :update]
  skip_before_action :registration_check

  def edit
    @on_profile_edit = true
  end

  def update
    if !@user.completed_registration && @user.update(profile_params)
      @user.update(completed_registration: true)
      if session[:invitation_code]
        apply_invitation_code(session[:invitation_code])
        session[:invitation_code] = nil
      end
      redirect_to root_url
    elsif @user.update(profile_params)
      redirect_to root_url
    else
      render :edit
    end
  end

  private

  def load_user
    @user = current_user
  end

  def profile_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :pronoun,
      :phone_number,
      :email,
      :bio,
      :quirky_fact,
      :specialties,
      :location_id,
      :github_username,
      :slack,
      :twitter,
      :skype,
      :slack,
      :company_name,
      :company_url,
      :custom_avatar
    )
  end

end
