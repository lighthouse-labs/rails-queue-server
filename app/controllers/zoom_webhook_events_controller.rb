class ZoomWebhookEventsController < ApplicationController

  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user
  skip_before_action :set_timezone

  before_action :ensure_valid_signature

  def create
    if params[:event] == 'meeting.ended'
      video_conference = VideoConference.find_by(zoom_meeting_id: params[:payload].dig('object', 'id'))
      if video_conference && video_conference.status != 'finished'
        # free user license
        end_zoom_meeting = ZoomMeeting::FreeUserLicense.call(
          update_user_stack: [{ user: { "id" => video_conference.zoom_host_id }, license: 1 }]
        )

        if video_conference.update(status: 'finished')
          # action cable to update cohort on new conference
          VideoConferenceChannel.update_conference(video_conference, VideoConferenceChannel.channel_name_from_cohort(video_conference.cohort))
        end
      end
    end
  end

  private

  def ensure_valid_signature
    credentials = Program.first&.settings.try(:[], 'zoom_credentials')
    credentials ||= {}
    verification_token = credentials['verification_token']
    render text: "Not a valid token", status: :unauthorized unless request.headers["authorization"] == verification_token
  end

end
