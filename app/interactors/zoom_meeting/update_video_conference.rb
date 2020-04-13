class ZoomMeeting::UpdateVideoConference

  include Interactor

  before do
    @zoom_meeting_id = context.zoom_meeting_id
    @video_conference_id = context.video_conference_id
    @options = context.options
  end

  def call
    video_conference = VideoConference.find_by(zoom_meeting_id: @zoom_meeting_id) if @zoom_meeting_id
    video_conference ||= VideoConference.find_by(id: @video_conference_id) if @video_conference_id

    context.fail!(error:  "No video conference to update.") unless video_conference
    
    if @options[:status] == 'finished' && video_conference.status != 'finished'
      end_meeting = ZoomMeeting::EndUserMeeting.call(
        video_conference: video_conference
      )
      context.fail!(error:  end_meeting.error) if end_meeting.failure?
    end

    if video_conference.update(@options)
      if @options[:status]
        # action cable to update cohort on new conference
        VideoConferenceChannel.update_conference(video_conference, VideoConferenceChannel.channel_name_from_cohort(video_conference.cohort))
      end
    else
      context.fail!(error:  "Could not update video conference.")
    end
    
  end

end
