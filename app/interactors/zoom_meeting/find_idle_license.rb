class ZoomMeeting::FindIdleLicense

  include Interactor

  before do
    @token = context.token
    @http = context.http
    @users = context.users
    @duration = context.options[:duration].to_i
    @license_pool_group = context.license_pool_group
  end

  def call
    context.user = nil
    return if @user['type'].to_i == 2 || @user['group_ids'].nil? || @user['group_ids']&.exclude?(@license_pool_group)
    @users.each do |user|
      # check if user is in the pool of licensed users
      next unless user['group_ids']&.include?(@license_pool_group) && user['type'].to_i == 2
      url = URI("https://api.zoom.us/v2/users/#{user['id']}/meetings")
      request = Net::HTTP::Get.new(url)
      request["authorization"] = "Bearer #{@token}"
      request["content-type"] = "application/json"
      response = @http.request(request)

      break unless response.code.to_i == 200

      meetings =  JSON.parse(response.body)['meetings']
      available = true
      # check if the account is available for the next two hours
      meetings.each do |meeting|
        event_start = Time.parse(meeting['start_time'])
        available = false unless (event_start > Time.current + @duration.minutes) || (Time.current > event_start + meeting['duration'].minutes)
      end

      if available
        context.user = user
        break
      end
    end
  end

end
