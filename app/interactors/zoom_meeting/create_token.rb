class ZoomMeeting::CreateToken

  include Interactor

  def call
    credentials = Program.first&.settings.try(:[], 'zoom_credentials')
    @API_KEY = credentials["api_key"]
    @API_SECRET = credentials["api_secret"]
    context.license_pool_group = credentials["license_pool_group"]

    payload = {
      iss: @API_KEY,
      exp: 1.hour.from_now.to_i
    }
    context.token = JWT.encode(payload, @API_SECRET, "HS256", typ: 'JWT')
    url = URI("https://api.zoom.us/v2/users")

    context.http = Net::HTTP.new(url.host, url.port)
    context.http.use_ssl = true
    context.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

end
