class ZoomMeeting::CreateVideoConference

  include Interactor

  before do
    @meeting = context.meeting
    @email = context.email
    @cohort = context.cohort
    @activity = context.activity
    @host = context[:options][:host]
  end

  def call
    VideoConference.create
    conference = VideoConference.new(
      name:            @meeting['topic'],
      start_time:      @meeting['start_time'],
      duration:        @meeting['duration'],
      status:          'waiting',
      zoom_meeting_id: @meeting['id'],
      zoom_host_id:    @meeting['host_id'],
      zoom_host_email: @email,
      start_url:       @meeting['start_url'],
      join_url:        @meeting['join_url'],
      password:        @meeting['password'],
      cohort_id:       @cohort&.id,
      activity_id:     @activity&.id
    )
    
    conference.user = @host

    if context.warnings[:update_user_license]
      conference.duration = 45
    else
      conference.licensed = true
    end

    context.fail!(error: 'Video Conference could not be created.') unless conference.save!
  end

end
