class ZoomMeeting::NewMeetingSetup

  include Interactor

  before do
    @options = context.options
  end

  def call
    context.activity = Activity.find_by id: @options[:activity_id]
    context.cohort = Cohort.find_by id: @options[:cohort_id]
    if @options[:host].hosting_active_video_conference?
      context.fail!(error: 'User already has an active video conference.')
    elsif context.activity&.active_conference_for_cohort(context.cohort)
      context.fail!(error: 'There is already a conference for that cohort and activity.')
    end

    context.email = @options[:email].present? ? @options[:email] : @options[:host].email
  end

end
