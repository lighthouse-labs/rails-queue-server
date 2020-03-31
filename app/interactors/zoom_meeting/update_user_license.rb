class ZoomMeeting::UpdateUserLicense

  include Interactor

  before do
    @token = context.token
    @http = context.http
    @update_user_stack = context.update_user_stack
  end

  def call
    until @update_user_stack.empty?
      current_user_info = @update_user_stack.pop
      license_type = current_user_info[:license]
      user = current_user_info[:user]

      context.fail!(error: "#{license_type} is an invalid account type") unless [1, 2].include? license_type

      next if user['type']&.to_i == license_type
      url = URI("https://api.zoom.us/v2/users/#{user['id']}")
      request = Net::HTTP::Patch.new(url)
      request["authorization"] = "Bearer #{@token}"
      request["content-type"] = "application/json"
      request.body = {
        type: license_type
      }.to_json
      response = @http.request(request)

      context.fail!(error: "No zoom licenses available") if response.body
    end
  end

end
