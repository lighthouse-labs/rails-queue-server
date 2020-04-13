class ZoomMeeting::UpdateUserLicense

  include Interactor

  before do
    @token = context.token
    @http = context.http
    @update_user_stack = context.update_user_stack
    @license_pool_group = context.license_pool_group
    @warning_text = "There were no available zoom licenses for you, your meeting will be limited by zoom to 45min in length. "
  end

  def call
    context.warnings ||= {}

    until @update_user_stack.empty?
      current_user_info = @update_user_stack.pop
      license_type = current_user_info[:license]
      user = current_user_info[:user]
      context.user = user

      context.fail!(error: "#{license_type} is an invalid account type") unless [1, 2].include? license_type

      next if user['type']&.to_i == license_type
      if user['group_ids'].nil? || user['group_ids']&.exclude?(@license_pool_group)
        if license_type == 2
          context.warnings[:update_user_license] = @warning_text + "If you want to create a licensed meeting for #{user['email']} assign them a license in zoom or add them to the zoom compass group."
        end
        next
      end

      url = URI("https://api.zoom.us/v2/users/#{user['id']}")
      request = Net::HTTP::Patch.new(url)
      request["authorization"] = "Bearer #{@token}"
      request["content-type"] = "application/json"
      request.body = {
        type: license_type
      }.to_json
      response = @http.request(request)

      if response.code.to_i == 204
        user['license'] = license_type
        context.warnings.delete(:update_user_license)
      else
        context.update_user_stack.push(current_user_info)
        context.warnings[:update_user_license] = @warning_text + JSON.parse(response.body)['message']
        break
      end
    end
  end

end
