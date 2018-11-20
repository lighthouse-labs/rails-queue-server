class QueueController < ApplicationController

  skip_before_action :authenticate_user

  def show
    # raise (Queue::LocationSerializer == LocationSerializer).inspect

    root = {
      locations: Location.active.to_a
    }
    @locations = Location.all
    @locations.each do |loc|
      root[:locations] << loc
    end
    # render json: QueueRootSerializer.new(root).as_json
    respond_to do |format|
      format.html
      format.js {
        render json: @locations, each_serializer: QueueLocationSerializer, root: false
      }
    end
  end

  private

  def render_location(loc)
    # data = {
    #   students: []
    # }

    # students = Student.active.in_active_cohort.where(location_id: loc)

    # students.each do |s|
    #   data[:students].push({
    #     id: s.id,
    #     first_name: s.first_name,
    #     last_name:  s.last_name,
    #     email:      s.email,
    #     avatar:
    #   })
    # end
  end

end
