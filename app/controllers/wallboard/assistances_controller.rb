class Wallboard::AssistancesController < Wallboard::BaseController

  def index
    location = Location.find_by(name: location_params)

    assistance_requests = AssistanceRequest.where(type: nil)
                                           .open_requests
                                           .oldest_requests_first
                                           .for_location(location)
                                           .map { |ar| AssistanceRequestSerializer.new(ar, root: false).as_json }

    render json: { assistance_requests: assistance_requests }
  end

  def assistances_params
    params.require(:location)
  end

end
