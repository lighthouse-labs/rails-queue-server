require 'net/http'

class ZoomMeetings
  
  def initialize
    @USER_ID = ENV["ZOOM_USER_ID"]
    @API_KEY = ENV["ZOOM_API_KEY"]
    @API_SECRET = ENV["ZOOM_API_SECRET"]
    @LECTURE_POOL_GROUP = "lr_FqZBBSDKjuMikOHNYOA"
  end
  
  def create_meeting
    begin
      payload = {
        iss: @API_KEY,
        exp: 1.hour.from_now.to_i
      }
      token = JWT.encode(payload, @API_SECRET, "HS256", { typ: 'JWT' })

      users = {
        vancouver: 4,
        toronto: 3
      }

      # url = URI("https://api.zoom.us/v2/users/#{userId[:vancouver]}/meetings")
      url = URI("https://api.zoom.us/v2/users")


      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(url)



      request["authorization"] = "Bearer #{token}"
      request["content-type"] = "application/json"


      response = http.request(request)

      # get users
      users =  JSON.parse(response.body)

      # from pool of licenced users check if any are free
      users.each do |user|
        
        if user[:group_ids].include? @LECTURE_POOL_GROUP
          # create a zooom with first available free account 
          url = URI("https://api.zoom.us/v2/users/#{user.id}/meetings")
          request = Net::HTTP::Get.new(url)
          request["authorization"] = "Bearer #{token}"
          request["content-type"] = "application/json"
          response = http.request(request)
          puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
          puts response.body.inspect

        end

      end




      return response

    rescue StandardError => err
      puts "Error creating zoom"
      puts err
      return nil
    end

    
  end

  private

  def uri_from_event(event)
    entry_points = event&.conference_data&.entry_points
    uri = nil
    entry_points&.each do |point|
      return point.uri if point.entry_point_type == 'video'
    end
  end

end
