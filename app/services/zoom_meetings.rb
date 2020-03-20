require 'net/http'

class ZoomMeetings
  
  def initialize
    @USER_ID = ENV["ZOOM_USER_ID"]
    @API_KEY = ENV["ZOOM_API_KEY"]
    @API_SECRET = ENV["ZOOM_API_SECRET"]
    @LECTURE_POOL_GROUP = "lr_FqZBBSDKjuMikOHNYOA"
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

      # url = URI("https://api.zoom.us/v2/users/#{userId[:vancouver]}/meetings")
      url = URI("https://api.zoom.us/v2/users")
      request = Net::HTTP::Get.new(url)

      request["authorization"] = "Bearer #{@token}"
      request["content-type"] = "application/json"

      response = @http.request(request)

      # get users
      users =  JSON.parse(response.body)['users']
      licensed_accounts = false
      # Check if user is in the organization

        # if user is paid create meeting

        #if use is not paid try to assign license

          #If cannot find license try to remove an idle licese from a user
          if remove_idle_license(users)
            # give license to user

            #book meeting
            book_meeting(user, start_time, duration, topic)
          end
  

      if licensed_accounts
        return {error: { message:'No licensed accounts in the compass pool are busy.'}}
      else
        return {error: { message:'No available accounts. Check that there are licensed accounts in the compass pool group.'}}
      end

    rescue StandardError => err
      puts "Error creating zoom"
      puts err
      return {error: { message:'internal server error', details: err}}
    end

    
  end

  private

  def add_license_to_user(user) 
    url = URI("https://api.zoom.us/v2/users/#{user['id']}")
    request = Net::HTTP::Patch.new(url)
    request["authorization"] = "Bearer #{@token}"
    request["content-type"] = "application/json"
    request.body = {
      type: 2
    }.to_json
    response = @http.request(request)
    res = JSON.parse(response.body)
    puts res.inspect
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
        # host_video: true,
        mute_upon_entry: true,
        join_before_host: true,
        approval_type: 0,
        audio: 'both',
        enforce_login: false,
        waiting_room: true
      }
    }.to_json
    response = @http.request(request)
    new_meeting =  JSON.parse(response.body)
    puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~'
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
      puts user.inspect
      if user['group_ids']&.include? @LECTURE_POOL_GROUP && user['type'] == 2
        licensed_accounts = true
        url = URI("https://api.zoom.us/v2/users/#{user['id']}/meetings")
        request = Net::HTTP::Get.new(url)
        request["authorization"] = "Bearer #{@token}"
        request["content-type"] = "application/json"
        response = @http.request(request)
        meetings =  JSON.parse(response.body)['meetings']
        available = true
        puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        puts response.body.inspect
        puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        # check if account is available for the next two hours
        meetings.each do |meeting|
          event_start = Time.parse(meeting['start_time'])
            # check if meeting ovrelaps with the next two hours
          unless (event_start > Time.now + 2.hours) || (Time.now > event_start + meeting['duration'].minutes)
            # can use account to create meeting
            puts 'meeting overlap'
            available = false
          end
        end

        if available 
          return true
        end
      end
    end
    return false
  end

end
