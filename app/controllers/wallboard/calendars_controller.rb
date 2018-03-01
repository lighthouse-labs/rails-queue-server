class Wallboard::CalendarsController < Wallboard::BaseController
  def index
    render json: { error: "Unable to find location #{location_params}" }, status: 422 unless location

    if location.calendar then
      render json: { calendar: { id: location.calendar } }
    else
      render json: { calendar: nil }, status: 404
    end
  end
end
