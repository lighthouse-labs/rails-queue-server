class ZoomMeeting::EndMeeting

  include Interactor

  before do
    @token = context.token
    @http = context.http
    @video_conference = context.video_conference
  end

  def call
    url = URI("https://api.zoom.us/v2/meetings/#{@video_conference.zoom_meeting_id}")
    request = Net::HTTP::Delete.new(url)
    request["authorization"] = "Bearer #{@token}"
    request["content-type"] = "application/json"
    response = @http.request(request)

    if response.code.to_i == 404
      context.warnings ||= {}
      context.warnings[:end_meeting] = JSON.parse(response.body)['message']
    elsif response.code.to_i != 204
      context.fail!(error: JSON.parse(response.body)['message'])
    end
    context.email = @video_conference.zoom_host_email
  end

end
