require 'net/http'

class ZoomMeetings

  def initialize
    @USER_ID = ENV["ZOOM_USER_ID"]
    @API_KEY = ENV["ZOOM_API_KEY"]
    @API_SECRET = ENV["ZOOM_API_SECRET"]
    @LICENSE_POOL_GROUP = ENV["ZOOM_LICENSE_POOL_GROUP"]
    @BASIC = 1
    @LICENSED = 2

    payload = {
      iss: @API_KEY,
      exp: 1.hour.from_now.to_i
    }
    @token = JWT.encode(payload, @API_SECRET, "HS256", typ: 'JWT')
    url = URI("https://api.zoom.us/v2/users")

    @http = Net::HTTP.new(url.host, url.port)
    @http.use_ssl = true
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  def create_meeting(host_user, start_time, duration, topic)
    url = URI("https://api.zoom.us/v2/users")
    request = Net::HTTP::Get.new(url)
    request["authorization"] = "Bearer #{@token}"
    request["content-type"] = "application/json"
    response = @http.request(request)
    users =  JSON.parse(response.body)['users']

    # Check if user is in the organization
    user = get_user_by_email(host_user.email, users)
    if user
      # if user has license create meeting
      if user['type'] == @LICENSED
        return book_meeting(user, start_time, duration, topic)
      else
        # if user does not have license try to assign license
        if update_user_license(user, @LICENSED)
          return book_meeting(user, start_time, duration, topic)
        else
          # If no available license try to remove an idle licese from a user in the pool
          if remove_idle_license(users)
            update_user_license(user, @LICENSED)
            return book_meeting(user, start_time, duration, topic)
          else
            return { error: { message: 'No licensed accounts in the compass pool are free.' } }
          end
        end
      end
    else
      return { error: { message: 'You do not have a zoom account with the organization.' } }
    end
  rescue StandardError => err
    puts "Error creating zoom"
    puts err
    Raven.capture_exception(err)
    { error: { message: 'internal server error', details: err } }
  end

  def end_meeting(video_conference)
    url = URI("https://api.zoom.us/v2/meetings/#{video_conference.zoom_meeting_id}/status")
    request = Net::HTTP::Put.new(url)
    request["authorization"] = "Bearer #{@token}"
    request["content-type"] = "application/json"
    request.body = {
      action: 'end'
    }.to_json
    response = @http.request(request)

    if response.body
      res = JSON.parse(response.body)
      return false if res['code'] != 3001
    end

    update_user_license({ "id" => video_conference.zoom_host_id }, @BASIC)
  end

  private

  def get_user_by_email(email, users)
    users.each do |user|
      return user if user['email'] == email
    end
    nil
  end

  def update_user_license(user, license_type)
    url = URI("https://api.zoom.us/v2/users/#{user['id']}")
    request = Net::HTTP::Patch.new(url)
    request["authorization"] = "Bearer #{@token}"
    request["content-type"] = "application/json"
    request.body = {
      type: license_type
    }.to_json
    response = @http.request(request)

    response.body ? false : true
  end

  def book_meeting(user, _start_time, duration, topic)
    url = URI("https://api.zoom.us/v2/users/#{user['id']}/meetings?type=live")
    request = Net::HTTP::Post.new(url)
    request["authorization"] = "Bearer #{@token}"
    request["content-type"] = "application/json"
    request.body = {
      topic:      topic,
      type:       2,
      start_time: Time.now,
      duration:   duration,
      agenda:     'A zoom meeting created in Compass.',
      settings:   {
        mute_upon_entry: true,
        approval_type:   2,
        audio:           'both',
        enforce_login:   false,
        waiting_room:    true
      }
    }.to_json
    response = @http.request(request)
    new_meeting = JSON.parse(response.body)

    new_meeting['message'] ? { error: { message: new_meeting['message'] } } : new_meeting
  end

  def remove_idle_license(users)
    users.each do |user|
      # check if user is in the pool of licensed users
      next unless user['group_ids']&.include?(@LICENSE_POOL_GROUP) && user['type'].to_i == 2
      licensed_accounts = true
      url = URI("https://api.zoom.us/v2/users/#{user['id']}/meetings")
      request = Net::HTTP::Get.new(url)
      request["authorization"] = "Bearer #{@token}"
      request["content-type"] = "application/json"
      response = @http.request(request)
      meetings =  JSON.parse(response.body)['meetings']
      available = true
      # check if the account is available for the next two hours
      meetings.each do |meeting|
        event_start = Time.parse(meeting['start_time'])
        available = false unless (event_start > Time.now + 2.hours) || (Time.now > event_start + meeting['duration'].minutes)
      end

      if available
        return true if update_user_license(user, @BASIC)
      end
    end
    false
  end

end
