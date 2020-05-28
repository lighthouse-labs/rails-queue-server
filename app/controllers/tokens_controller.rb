class TokensController < ApplicationController

  skip_before_action :authenticate_user
  before_action :auth_compass_instance

  def create
    payload = token_params[:user].to_h
    payload[:compass_instance_id] = @compass_instance.id
    payload[:access] ||= []

    # token secret should be rotating and not stored in env
    token = JWT.encode payload, ENV['TOKEN_SECRET'], 'HS256'
    render json: { token: token }
  end

  private

  def token_params
    all_options = params.require(:token_options)[:user].try(:permit!)
    params.require(:token_options).permit(:key, :secret).merge(user: all_options)
  end

  def auth_compass_instance
    @compass_instance = CompassInstance.find_by(key: token_params[:key])
    if !@compass_instance || BCrypt::Password.new(@compass_instance&.secret) != token_params[:secret]
      render json: { error: 'Incorrect key or secret.' }
    else
      Octopus.using(@compass_instance.name) do
        user = User.find_by(uid: token_params['user'].try(:[], :uid))
        render json: { error: 'Invalid UID.' } unless user
      end
    end
  end

end
