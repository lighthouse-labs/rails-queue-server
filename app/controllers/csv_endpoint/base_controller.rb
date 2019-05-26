class CsvEndpoint::BaseController < ActionController::Base

  before_action :verify_token

  def csv_header(field_mapping)
    field_mapping.map { |e| e[:header] }
  end

  def get_select_fields(field_mapping)
    field_mapping.map { |e| e[:statement] }
  end

  def get_field_mappings(requested_fields = nil)
    requested_fields.nil? ? field_mapping_arr.values : requested_fields.map { |e| field_mapping_arr[e.to_sym] }
  end

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
