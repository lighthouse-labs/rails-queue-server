class Wallboard::TeachersController < Wallboard::BaseController

  def index
    location = Location.find_by(name: teachers_params)

    unless location
      render json: { error: "Unable to find location #{teachers_params}" }, status: 422
      return
    end

    teachers = Teacher.filter_by_location(location.id)
                      .where(on_duty: true)
                      .order(:id)
                      .map { |u| TeacherSerializer.new(u, root: false) }

    render json: { teachers: teachers }
  end

  private

  def teachers_params
    params.require(:location)
  end

end
