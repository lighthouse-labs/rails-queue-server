class ZoomMeeting::CreateToken

  include Interactor

  def call
    @USER_ID = ENV["ZOOM_USER_ID"]
    @API_KEY = ENV["ZOOM_API_KEY"]
    @API_SECRET = ENV["ZOOM_API_SECRET"]
    context.license_pool_group = ENV["ZOOM_LICENSE_POOL_GROUP"]

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
