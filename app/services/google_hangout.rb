require 'googleauth'
require 'google/apis/calendar_v3'

class GoogleHangout

  def initialize
    @APPLICATION_NAME = "CompassHangoutsMeet".freeze
    @CREDENTIALS_PATH = './compasshangoutsmeet-ab3be389f157.json'.freeze
    scope = ['https://www.googleapis.com/auth/admin.directory.resource.calendar', 'https://www.googleapis.com/auth/calendar']

    @authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(@CREDENTIALS_PATH),
      scope:       scope
    )

    @authorizer.fetch_access_token!
  end

  def create_hangout(asssistor, assistee)
    # Initialize the API
    service = Google::Apis::CalendarV3::CalendarService.new
    service.client_options.application_name = @APPLICATION_NAME
    service.authorization = @authorizer

    now = DateTime.now
    event = Google::Apis::CalendarV3::Event.new(
      summary:         "Assistance Request Between #{asssistor.full_name} and #{assistee.full_name}",
      location:        (assistee.location&.name).to_s,
      description:     'This event was automatically created by the HangoutsCreator Service Account',
      start:           Google::Apis::CalendarV3::EventDateTime.new(
        date_time: now.to_s
      ),
      end:             Google::Apis::CalendarV3::EventDateTime.new(
        date_time: now.new_offset('+00:30').to_s
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
    entry_points&.each do |point|
      return point.uri if point.entry_point_type == 'video'
    end
  end

end
