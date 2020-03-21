class Teacher::VideoConferencesController < Teacher::BaseController

  def index
    
    zoom = ZoomMeetings.new

    res = zoom.create_meeting(@current_user, 130, 'Lecture')

    if res[:error]
      #send error
      
    end

    render json: { test: 'stuff' }

  end

  def update
    video_conference = VideoConference.find(params[:id])

    zoom_update = true
    old_status = video_conference.status
    if conference_params[:status] == 'finished' && video_conference.status != 'finished'
      # use zoom api to finish conference
      zoom = ZoomMeetings.new
      zoom_update = zoom.end_meeting(video_conference)
    end

    if zoom_update && video_conference.update_attributes(conference_params)
      if conference_params[:status]
        # action cable to update cohort on new conference
        VideoConferenceChannel.update_conference(video_conference, VideoConferenceChannel.channel_name_from_cohort(video_conference.cohort))
      end
      flash[:notice] = "Video Conference Updated"
    else
      flash[:alert] = "Video Conferene Could not be Updated"
    end

    redirect_back fallback_location: root_path
  end

  def create
    
    zoom = ZoomMeetings.new
    #check if there is already an active conferenect
    # VideoConference.for_activity(conference_params[:activity_id])&.for_cohort(conference_params[:cohort_id])

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
        duration: res['duration'], 
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
      :cohort_id, :activity_id, :topic, :duration, :start_time, :status
    )
   end

end
