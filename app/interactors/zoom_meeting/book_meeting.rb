class ZoomMeeting::BookMeeting

  include Interactor

  before do
    @token = context.token
    @http = context.http
    @user = context.user
    @topic = context.topic
    @duration = context.duration
    @use_password = context.use_password
  end

  def call
    url = URI("https://api.zoom.us/v2/users/#{@user['id']}/meetings?type=live")
    request = Net::HTTP::Post.new(url)
    request["authorization"] = "Bearer #{@token}"
    request["content-type"] = "application/json"
    options = {
      topic:      @topic,
      type:       2,
      start_time: Time.current,
      duration:   @duration,
      agenda:     'A zoom meeting created in Compass.',
      settings:   {
        mute_upon_entry: true,
        approval_type:   2,
        audio:           'both',
        enforce_login:   false,
        waiting_room:    true,
        auto_recording:  'cloud'
      }
    }
    options[:password] = Faker::Hacker.adjective if @use_password == 'true'
    request.body = options.to_json
    response = @http.request(request)
    body = JSON.parse(response.body)

    context.fail!(error: body['message']) unless response.code.to_i == 201

    context.meeting = body
  end

end
