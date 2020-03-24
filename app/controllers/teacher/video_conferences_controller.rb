class Teacher::VideoConferencesController < Teacher::BaseController

  def show
    @video_conference = VideoConference.find params[:id]
    session[:cohort_id] = @video_conference.cohort.id if @video_conference.cohort?
    redirect_to @video_conference.activity_id? ? activity_path(@video_conference.activity) : :root
  end

  def update
    video_conference = VideoConference.find(params[:id])

    zoom_update = true
    old_status = video_conference.status
    if conference_params[:status] == 'finished' && video_conference.status != 'finished'
      zoom = ZoomMeetings.new
      zoom_update = zoom.end_meeting(video_conference)
    end

    if zoom_update && video_conference.update(conference_params)
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
    activity = Activity.find_by_id conference_params[:activity_id]
    cohort = Cohort.find_by_id conference_params[:cohort_id]
    if @current_user.hosting_active_video_conference?
      res = { error: { message: 'User already has an active video conference.' } }
    elsif activity&.active_conference_for_cohort(cohort)
      res = { error: { message: 'There is already a conference for that cohort and activity.' } }
    else
      zoom = ZoomMeetings.new
      res = zoom.create_meeting(@current_user, conference_params[:start_time], conference_params[:duration], conference_params[:topic])
    end

    if res[:error]
      flash[:alert] = (res[:error][:message]).to_s
    else
      VideoConference.create
      conference = VideoConference.new(
        start_time:      res['start_time'],
        duration:        res['duration'],
        status:          'waiting',
        zoom_meeting_id: res['id'],
        zoom_host_id:    res['host_id'],
        start_url:       res['start_url'],
        join_url:        res['join_url'],
        cohort_id:       cohort&.id,
        activity_id:     activity&.id
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
