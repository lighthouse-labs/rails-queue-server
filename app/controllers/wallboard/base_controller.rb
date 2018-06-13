class Wallboard::BaseController < ActionController::Base

  before_action :verify_token

  private

  def location
    Location.find_by(name: location_params)
  end

  def location_params
    params.require(:location)
  end

  def verify_token
    render json: { error: 'Unauthorized' }, status: :unauthorized unless get_token == "Bearer #{auth_token}"
  end

  def get_token
    request.headers['Authorization']
  end

  def auth_token
    ENV['WALLBOARD_TOKEN']
  end

end