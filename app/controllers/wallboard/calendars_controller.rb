class Wallboard::CalendarsController < Wallboard::BaseController

  def index
    return render json: { error: "Unable to find location #{location_params}" }, status: :unprocessable_entity unless location

    if location.calendar
      render json: { calendar: { id: location.calendar } }
    else
      render json: { calendar: nil }, status: :not_found
    end
  end

end
