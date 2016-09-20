class InvitationsController < ApplicationController
  skip_before_action :authenticate_user, only: [:show]

  def show
    if current_user
      apply_invitation_code(params[:code])
    else
      flash[:notice] = "Please authenticate via GitHub to gain access with code '#{params[:code]}'"
      session[:invitation_code] = params[:code]
    end

    redirect_to new_session_path
  end
end
