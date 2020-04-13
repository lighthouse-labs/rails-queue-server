class ZoomWebhookEventsController < ApplicationController

  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user
  skip_before_action :set_timezone

  before_action :ensure_valid_signature

  def create
    if params[:event] == 'meeting.ended'
      zoom_update = ZoomMeeting::UpdateVideoConference.call(
        zoom_meeting_id: params[:payload].dig('object', 'id'),
        options:         { status: 'finished' }
      )
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
