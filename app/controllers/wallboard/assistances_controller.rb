class Wallboard::AssistancesController < Wallboard::BaseController
  def index
    assistances = AssistanceRequest.where(type: nil)
      .open_requests
      .oldest_requests_first
      .requestor_cohort_in_locations([location_params])
      .map { |ar| AssistanceRequestSerializer.new(ar, root: false).as_json  }

    render json: { assistances: assistances }
  end

  def assistances_params
    params.require(:location)
  end
end
