class ZoomMeeting::GetPoolUsers

  include Interactor

  before do
    @token = context.token
    @http = context.http
  end

  def call
    url = URI("https://api.zoom.us/v2/users")
    request = Net::HTTP::Get.new(url)
    request["authorization"] = "Bearer #{@token}"
    request["content-type"] = "application/json"
    response = @http.request(request)
    body = JSON.parse(response.body)

    context.fail!(error: body['message']) unless response.code.to_i == 200

    context.users = body['users']
  end

end
