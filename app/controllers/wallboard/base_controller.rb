class Wallboard::BaseController < ActionController::Base
  before_action :verify_token


  private

  def verify_token
    unless get_token == "Bearer #{auth_token}"
      render json: {error: 'Unauthorized'}, status: 401
    end
  end

  def get_token
    request.headers['Authorization']
  end

  def auth_token
    Rails.application.secrets.wallboard_access_token
  end
end
