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
    # raise cohort.student_locations.inspect if cohort.student_locations.size > 1
    cohort.student_locations.each do |location|
      handle_cohort_location(cohort, location)
    end
  end

  def handle_cohort_location(cohort, location)
    puts "Handling cohort #{cohort.name}"

    # if there are any active interviews in this location, then no go
    if interview = TechInterview.interviewee_location(location).active.first
      return handle_existing_interview(cohort, location, interview)
    end

    interview_templates.each do |template|
      if template.week <= cohort.week
        if create_interview(cohort, location, template)
          # return if interview created, b/c we are done for that cohort+location combo
          # if create_interview doesnt create one, it returns nil
          return
        end
      end
    end
  end

  def handle_existing_interview(cohort, location, interview)
    puts "Existing W#{interview.week } interview found for #{location.name}: #{interview.id}"

    if should_slack?(interview)
      slack_alert interview, generate_slack_message(cohort, location, interview)
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

  def generate_slack_message(cohort, location, interview)
    stale_for = (Time.current - interview.created_at).to_i / 60
    stale_for = (stale_for > 60) ? "#{stale_for / 60} hrs" : "#{stale_for} mins"
    "There's a stale tech interview in #{location.name} Queue: #{interview.interviewee.full_name} [#{stale_for}]."
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

  def create_interview(cohort, location, template)
    if student = fetch_student(cohort, location, template)
      puts "Creating W#{template.week} interview for #{cohort.name} in #{location.name}: #{student.full_name}"
      return CreateTechInterview.call(
        interviewee: student,
        interview_template: template
      )
    end
    nil
  end

  def fetch_student(cohort, location, template)
    interviewed_student_ids = template.tech_interviews.for_cohort(cohort).select(:interviewee_id)
    cohort.students.active.where.not(id: interviewed_student_ids).where(location_id: location.id).order('random()').first
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
