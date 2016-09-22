class TechInterviewCreator

  def run
    # no tech interviews on weekends
    puts "Running..."
    return false unless weekday?
    Cohort.is_active.each do |cohort|
      tz = cohort.location.timezone
      Time.use_zone(tz) do
        if within_mentor_hours?
          handle_cohort(cohort)
        end
      end
    end
  end

  private

  def handle_cohort(cohort)
    puts "Handling cohort #{cohort.name}"

    # if there are any active interviews in this location, then no go
    if interview = TechInterview.for_locations([cohort.location.name]).active.first
      return handle_existing_interview(cohort, interview)
    end

    interview_templates.each do |template|
      if template.week <= cohort.week
        if interview = create_interview(cohort, template)
          return interview
        end
      end
    end
  end

  def handle_existing_interview(cohort, interview)
    puts "Existing W#{interview.week } interview found for #{cohort.location.name}: #{interview.id}"

    if should_slack?(interview)
      slack_alert interview, generate_slack_message(cohort, interview)
    end
  end

  def should_slack?(interview)
    mins = 30
    ENV['SLACK_WEBHOOK_QUEUE_ALERTS'].present? &&
      interview.queued? &&
      interview.num_alerts < 3 &&
      interview_stale_for(interview, mins)
  end

  def interview_stale_for(interview, mins)
    (Time.current - (interview.last_alerted_at || interview.created_at) >= (mins * 60))
  end

  def generate_slack_message(cohort, interview)
    stale_for = (Time.current - interview.created_at).to_i / 60
    stale_for = (stale_for > 60) ? "#{stale_for / 60} hrs" : "#{stale_for} mins"
    "There's a stale tech interview in #{cohort.location.name} Queue: #{interview.interviewee.full_name} [#{stale_for}]."
  end

  def slack_alert(interview, msg)
    puts "SLACKING team about stale interview #{interview.id}"

    result = NotifySlackChannel.call(
      webhook: ENV['SLACK_WEBHOOK_QUEUE_ALERTS'],
      message: msg
    )

    if result.success?
      interview.touch(:last_alerted_at)
      TechInterview.increment_counter(:num_alerts, interview.id)
    end
  end

  def create_interview(cohort, template)
    puts "Creating W#{template.week} interview for #{cohort.name}"

    if student = fetch_student(cohort, template)
      result = CreateTechInterview.call(
        interviewee: student,
        interview_template: template
      )
    end
  end

  def fetch_student(cohort, template)
    interviewed_student_ids = template.tech_interviews.for_cohort(cohort).select(:interviewee_id)
    cohort.students.active.where.not(id: interviewed_student_ids).order('random()').first
  end

  def within_mentor_hours?
    hour = Time.current.hour
    hour >= 11 && hour < 21
  end

  def weekday?
    Date.current.on_weekday?
  end

  def interview_templates
    @interview_templates ||= TechInterviewTemplate.all
  end

end