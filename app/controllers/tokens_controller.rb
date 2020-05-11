class TokensController < ApplicationController
  skip_before_action :authenticate_user
  before_action :auth_compass_instance

  def create
    payload = { user_uid: token_params[:user_uid], compass_instance_id: @compass_instance.id }

    # token secret should be rotating and not stored in env
    token = JWT.encode payload, ENV['TOKEN_SECRET'], 'HS256'
    render json: {token: token}
  end

  private

  def token_params
    params.require(:token_options).permit(:key, :secret, :user_uid)
  end

  def auth_compass_instance
    @compass_instance = CompassInstance.find_by(key: token_params[:key])
    Octopus.using(@compass_instance.name) do
      @user = User.find_by(uid: token_params[:user_uid])
      if !@compass_instance || BCrypt::Password.new(@compass_instance&.secret) != token_params[:secret]
        render json: { error: 'Incorrect key or secret.' }
      elsif !@user
        render json: { error: 'Invalid UID.' }
      end
    end
  end

end
