class CsvEndpoint::BaseController < ActionController::Base

  before_action :verify_token

  private

  def verify_token
    render json: { error: 'Unauthorized' }, status: :unauthorized unless get_token == auth_token
  end

  def get_token
    params[:token]
  end

  def auth_token
    ENV['CSV_ENDPOINT_TOKEN']
  end

end
