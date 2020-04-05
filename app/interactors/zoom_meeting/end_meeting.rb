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

    unless response.code.to_i == 204
      body = JSON.parse(response.body)
      context.fail!(error: body['message'])
    end
    context.update_user_stack ||= []
    context.update_user_stack.push(user: { "id" => @video_conference.zoom_host_id }, license: 1)
  end

end
