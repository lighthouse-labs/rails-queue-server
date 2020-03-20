class Teacher::VideoConferencesController < Teacher::BaseController

  def index
    
    zoom = ZoomMeetings.new

    res = zoom.create_meeting(@current_user, 130, 'Lecture')

    if res[:error]
      #send error
      
    end

    render json: { test: 'stuff' }

  end

  def create
    
    zoom = ZoomMeetings.new

    # create zoom meeting
    res = zoom.create_meeting(@current_user, conference_params[:start_time], conference_params[:duration], conference_params[:topic])

    if res[:error]
      #send error
      flash[:alert] = "#{res[:error][:message]}"
    else
      # create conference entity
      VideoConference.create()
      conference = VideoConference.new(
        start_time: res['start_time'], 
        duration: res['start_time'], 
        status: 'waiting', 
        zoom_meeting_id: res['id'], 
        start_url: res['start_url'], 
        join_url: res['join_url'],
        cohort_id: conference_params[:cohort_id],
        activity_id: conference_params[:activity_id]
      )
      conference.user = current_user

      if conference.save!
        flash[:notice] = "Video Conference Created"
      else
        flash[:alert] = "conference could not be saved"
      end

    end
    redirect_back fallback_location: root_path
  end

  private

  def conference_params
    params.require(:video_conference).permit(
      :cohort_id, :activity_id, :topic, :duration, :start_time
    )
   end

end
