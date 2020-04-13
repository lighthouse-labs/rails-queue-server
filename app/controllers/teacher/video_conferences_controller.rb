class Teacher::VideoConferencesController < Teacher::BaseController

  def show
    @video_conference = VideoConference.find params[:id]
    session[:cohort_id] = @video_conference.cohort.id if @video_conference.cohort?
    redirect_to @video_conference.activity_id? ? activity_path(@video_conference.activity) : :root
  end

  def update

    zoom_update = ZoomMeeting::UpdateVideoConference.call(
      video_conference_id: params[:id],
      options: conference_params
    )

    if zoom_update.success?
      flash[:notice] = case conference_params[:status]
                       when 'finished'
                         "Video Conference Ended"
                       when 'waiting'
                         "Video Conference In Test Mode"
                       when 'started'
                         "Video Conference Started"
                       when 'broadcast'
                         "Video Conference Broadcasting"
                       else
                         "Video Conference Updated"
                       end

    else
      flash[:alert] = zoom_update.error
    end

    redirect_back fallback_location: root_path
  end

  def create
    options = conference_params
    options[:cohort_id] ||= cohort&.id
    options[:host] = current_user
    create_zoom_meeting = ZoomMeeting::CreateUserMeeting.call(
      options:      options
    )

    if create_zoom_meeting.success?
      flash[:notice] = "Video Conference Created"

      if create_zoom_meeting.warnings.present?
        warning_message = ''
        create_zoom_meeting.warnings.each do |type, message|
          warning_message += " #{message}"
        end
        flash[:alert] = warning_message
      end

    else
      flash[:alert] = create_zoom_meeting.error
    end
    
    redirect_back fallback_location: root_path
  end

  private

  def conference_params
    params.require(:video_conference).permit(
      :cohort_id, :activity_id, :topic, :duration, :start_time, :status, :use_password, :email, :cohort_id
    )
   end

end
