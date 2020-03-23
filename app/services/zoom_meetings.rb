require 'net/http'

class ZoomMeetings
  
  def initialize
    @USER_ID = ENV["ZOOM_USER_ID"]
    @API_KEY = ENV["ZOOM_API_KEY"]
    @API_SECRET = ENV["ZOOM_API_SECRET"]
    @LECTURE_POOL_GROUP = "lr_FqZBBSDKjuMikOHNYOA"
    @BASIC = 1
    @LICENSED = 2
    payload = {
      iss: @API_KEY,
      exp: 1.hour.from_now.to_i
    }
    @token = JWT.encode(payload, @API_SECRET, "HS256", { typ: 'JWT' })
    url = URI("https://api.zoom.us/v2/users")


    @http = Net::HTTP.new(url.host, url.port)
    @http.use_ssl = true
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
  
  def create_meeting(host_user, start_time, duration, topic)
    begin

      # setup request
      url = URI("https://api.zoom.us/v2/users")
      request = Net::HTTP::Get.new(url)
      request["authorization"] = "Bearer #{@token}"
      request["content-type"] = "application/json"
      # get users
      response = @http.request(request)
      users =  JSON.parse(response.body)['users']
      # Check if user is in the organization
      user = get_user_by_email(host_user.email, users)
      if user
        # if user is paid create meeting
        if user['type'] == @LICENSED
          ### make sure user does not have a meeting already created

          return book_meeting(user, start_time, duration, topic)
        else
          #if use is not paid try to assign license
          if update_user_license(user, @LICENSED)
            return book_meeting(user, start_time, duration, topic)
          else
            #If cannot find license try to remove an idle licese from a user in compass group
            if remove_idle_license(users)
              update_user_license(user, @LICENSED)  
              return book_meeting(user, start_time, duration, topic)
            else
              return {error: { message:'No licensed accounts in the compass pool are free.'}}
            end
          end
        end
      else
        return {error: { message:'You do not have a zoom account with lighthouselabs.'}}
      end

    rescue StandardError => err
      puts "Error creating zoom"
      puts err
      return {error: { message:'internal server error', details: err}}
    end

  end

  def end_meeting(video_conference)
    url = URI("https://api.zoom.us/v2/meetings/#{video_conference.zoom_meeting_id}/status")

    # attendance logic could be added here

    request = Net::HTTP::Put.new(url)
    request["authorization"] = "Bearer #{@token}"
    request["content-type"] = "application/json"
    request.body = {
      action: 'end'
    }.to_json
    response = @http.request(request)
    if response.body
      res = JSON.parse(response.body)
      if res['code'] != 3001
        puts '~error ending meeting~~~~~~~~~~~~~~~~~~~'
        puts res.inspect
        puts '~~~~~~~~~~~~~~~~~~~~'
        return false 
      end
    end
    update_user_license({"id" => video_conference.zoom_host_id}, @BASIC)
    return true

  end

  private

  def get_user_by_email(email, users)
    users.each do |user|
      puts user
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
    if response.body
      res = JSON.parse(response.body)
      puts '~error user license~~~~~~~~~~~~~~~~~~~'
      puts res.inspect
      puts '~~~~~~~~~~~~~~~~~~~~'
      return false
    else 
      return true
    end
  end

  def book_meeting(user, start_time, duration, topic)
    url = URI("https://api.zoom.us/v2/users/#{user['id']}/meetings?type=live")
    request = Net::HTTP::Post.new(url)
    request["authorization"] = "Bearer #{@token}"
    request["content-type"] = "application/json"
    request.body = {
      topic: topic,
      type: 2,
      start_time: Time.now,
      duration: duration,
      agenda: 'a lecture about ',
      settings: {
        mute_upon_entry: true,
        approval_type: 2,
        audio: 'both',
        enforce_login: false,
        waiting_room: true
      }
    }.to_json
    response = @http.request(request)
    new_meeting =  JSON.parse(response.body)
    puts '~new meeting~~~~~~~~~~~~~~~~~~~~~~~~~~'
    puts new_meeting
    puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    if new_meeting['message']
      return {error: { message: new_meeting['message']}}
    else 
      return new_meeting
    end
  end

  def remove_idle_license(users)
    # from pool of licenced users check if any are free
    users.each do |user|
      if user['group_ids']&.include?(@LECTURE_POOL_GROUP) && user['type'].to_i == 2
        licensed_accounts = true
        url = URI("https://api.zoom.us/v2/users/#{user['id']}/meetings")
        request = Net::HTTP::Get.new(url)
        request["authorization"] = "Bearer #{@token}"
        request["content-type"] = "application/json"
        response = @http.request(request)
        meetings =  JSON.parse(response.body)['meetings']
        available = true
        puts '~meetings~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        puts response.body.inspect
        puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        # check if account is available for the next two hours
        meetings.each do |meeting|
          event_start = Time.parse(meeting['start_time'])
            # check if meeting ovrelaps with the next two hours
          unless (event_start > Time.now + 2.hours) || (Time.now > event_start + meeting['duration'].minutes)
            # cant use account to create meeting
            puts 'meeting overlap'
            available = false
          end
        end
        puts user.inspect
        if available
          update_user_license(user, @BASIC)  
          return true
        end
      end
    end
    return false
  end

end
