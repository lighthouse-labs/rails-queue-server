class Teacher::ConferencesController < Teacher::BaseController

  def index
    
    zoom = ZoomMeetings.new

    res = zoom.create_meeting

    render json: { test: 'stuff' }

  end

end
