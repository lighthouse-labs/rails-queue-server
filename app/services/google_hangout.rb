require 'googleauth'
require 'google/apis/calendar_v3'

class GoogleHangout

  def initialize
    @APPLICATION_NAME = "CompassHangoutsMeet".freeze
    @scope = 'https://www.googleapis.com/auth/calendar.events'
  end

  def create_hangout(assistor, assistee)
    @authorizer = ::Google::Auth::ServiceAccountCredentials.make_creds(
      scope: @scope
    )

    # if ENV["GOOGLE_SUB_EMAIL"]
    #   google_org_domain = ENV["GOOGLE_SUB_EMAIL"].split('@').last
    #   @authorizer.sub = ENV["GOOGLE_SUB_EMAIL"] if assistee.email.split('@').last == google_org_domain || assistor.email.split('@').last == google_org_domain
    # end

    @authorizer.fetch_access_token!
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = @authorizer

    now = DateTime.now

    event = {
      summary:         "Assistance Request Between #{assistor.try(:full_name) || assistor.try(:[], 'fullName')} and #{assistee['fullName']}",
      location:        assistee.dig('info', 'location'),
      description:     'This event was automatically created by the HangoutsCreator Service Account',
      guestsCanModify: true,
      start:           {
        dateTime: now.to_s
      },
      end:             {
        dateTime: now.new_offset('+00:30').to_s
      },
      # attendees: [
      #   Google::Apis::CalendarV3::EventAttendee.new(
      #     email: assistor.email
      #   ),
      #   Google::Apis::CalendarV3::EventAttendee.new(
      #     email: assistee.email
      #   )
      # ],
      conferenceData:  {
        createRequest: {
          conferenceSolutionKey: { type: 'eventHangout' },
          requestId:             SecureRandom.uuid
        }
      }
    }.to_json

    result = service.insert_event('primary', event, conference_data_version: 1, options: { skip_serialization: true })
    event_details(result)
  rescue StandardError => e
    Raven.capture_exception(e)
    nil
  end

  private

  def event_details(event)
    entry_points = event&.conference_data&.entry_points
    uri = nil
    entry_points&.each do |point|
      return { uri: point.uri, type: event&.conference_data&.conference_solution&.key&.type } if point.entry_point_type == 'video'
    end
  end

end
