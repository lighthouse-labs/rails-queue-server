require 'googleauth'
require 'google/apis/calendar_v3'

class GoogleHangout

  def initialize
    @APPLICATION_NAME = "CompassHangoutsMeet".freeze
    @CREDENTIALS_PATH = './compasshangoutsmeet-ab3be389f157.json'.freeze
    scope = ['https://www.googleapis.com/auth/admin.directory.resource.calendar', 'https://www.googleapis.com/auth/calendar']
  
    @authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(@CREDENTIALS_PATH),
      scope: scope)
  
    @authorizer.fetch_access_token!
  
  end

  def create_hangout

    # Initialize the API
    service = Google::Apis::CalendarV3::CalendarService.new
    service.client_options.application_name = @APPLICATION_NAME
    service.authorization = @authorizer

    # # Fetch the next 10 events for the user
    # calendar_id = "primary"
    # response = service.list_events(calendar_id,
    #                               max_results:   10,
    #                               single_events: true,
    #                               order_by:      "startTime",
    #                               time_min:      DateTime.now.rfc3339)
    # puts "Upcoming events:"
    # puts "No upcoming events found" if response.items.empty?
    # response.items.each do |event|
    #   start = event.start.date || event.start.date_time
    #   puts "-------------------------- #{event.conference_data&.entry_points.inspect} -----------------------------"
    #   p event
    # end

    event = Google::Apis::CalendarV3::Event.new(
      summary: "test meet event",
      location: '800 Howard St., San Francisco, CA 94103',
      description: 'A chance to hear more about Google\'s developer products.',
      start: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: '2020-05-28T09:00:00-07:00',
        time_zone: 'America/Los_Angeles'
      ),
      end: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: '2020-05-28T17:00:00-07:00',
        time_zone: 'America/Los_Angeles'
      ),
      # attendees: [
      #   Google::Apis::CalendarV3::EventAttendee.new(
      #     email: 'travis@lighthouselabs.com'
      #   )
      # ],
      ## for google hangouts
      conference_data: {
        create_request: {
            request_id: SecureRandom.uuid
        }
      },
      # #for google meets
      # conference_data: {
      #   conference_solution: {
      #       key: {
      #         type: 'hangoutsMeet'
      #       }
      #   },
      #   create_request: {
      #      request_id: SecureRandom.uuid
      #   }
      # },
    )

    result = service.insert_event('primary', event, conference_data_version: 1)
    uri_from_event(result)

  end

  private

  def uri_from_event(event) 
    entry_points = event&.conference_data&.entry_points
    uri = nil
    if entry_points
      entry_points.each do |point|
        return point.uri if point.entry_point_type == 'video'
      end
    end
  end

end
