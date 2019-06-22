module ActivitiesHelper

  def activity_average_time(activity)
    if activity.average_time_spent? && activity.duration?
      (activity.duration + activity.average_time_spent) / 2.0
    elsif activity.average_time_spent?
      activity.average_time_spent
    elsif activity.duration?
      activity.duration
    else
      0
    end
  end

  def core_duration_in_hours(activities, workbook = nil)
    (activities.inject(0) do |sum, activity|
      if !stretch_activity?(activity, workbook) && activity.active?
        sum + activity_average_time(activity)
      else
        sum
      end
    end) / 60.0 * 1.1
  end

  def stretch_duration_in_hours(activities, workbook = nil)
    (activities.inject(0) do |sum, activity|
      if stretch_activity?(activity, workbook) && activity.active?
        sum + activity_average_time(activity)
      else
        sum
      end
    end) / 60.0 * 1.1
  end

  def stretch_activity?(activity, workbook = nil)
    if workbook
      workbook.stretch_activity?(activity)
    else
      activity.stretch?
    end
  end

  def get_activity_path(activity, workbook = nil, current_activity = nil)
    return get_next_index_path(current_activity, workbook) if activity.blank? && current_activity
    if workbook
      workbook_activity_path(workbook, activity)
    elsif activity.prep?
      prep_activity_path(:prep, activity)
    elsif activity.teachers_only?
      activity_path(activity)
    else
      day_activity_path(activity.day, activity)
    end
  end

  def get_next_index_path(activity, workbook = nil)
    if workbook
      workbook_path(workbook)
    elsif activity.section && activity.section.type == "Prep"
      prep_index_path
    elsif activity.day
      day_path(activity.day)
    else
      root_path
    end
  end

  def assistance_activities_grouped_by_day_for_select
    if current_user
      grouped_options_for_select(
        current_user.visible_bootcamp_activities.assistance_worthy.pluck(:name, :day, :id).group_by { |d| d[1] },
        @activity.try(:id)
      )
    end
  end

  def markdown(content, renderer = CompassMarkdownRenderer)
    return '' if content.nil?
    options = {
      autolink:            true,
      space_after_headers: true,
      fenced_code_blocks:  true,
      tables:              true,
      strikethrough:       true
    }
    @markdown ||= Redcarpet::Markdown.new(renderer, options)
    @markdown.render(content)
  end

  def duration_in_hours(duration)
    number_with_precision (duration.to_f / 60), precision: 2, strip_insignificant_zeros: true
  end

  def descriptive_activity_name(activity)
    name = activity.name
    name << ' (Stretch)' if stretch_activity?(activity, @workbook)
    name << ' [Archived]' if activity.archived?
    name
  end

  def duration(activity)
    if @program.display_exact_activity_duration? && activity.display_duration?
      duration_range activity
    else
      vague_duration activity
    end
  end

  def vague_duration(activity)
    duration = activity.duration.to_i
    if duration > 0 && duration <= 30
      'Tiny'
    elsif duration > 30 && duration <= 60
      'Short'
    elsif duration > 60 && duration < 120
      'Medium'
    elsif duration >= 120
      'Long'
    else # 0 / nil
      ''
    end
  end

  # returns either an array of 2 numbers, both actual and estimate (if there's enough of a differece between actual and estimate)
  # or just a number (no range, just a single number since estimate and actuals are close)
  def duration_range(activity)
    durations = activity.duration_range
    if durations.size == 2 && (durations[1] - durations[0] >= 15)
      [round5(durations[0]), round5(durations[1])]
    else
      round5([durations.first, durations.last].max)
    end
  end

  # round number to nearest increment of 5 (12.5 => 15; 12 => 10; 13 => 15; etc)
  def round5(number)
    (number.to_f / 5).round * 5
  end

  def activity_type(activity)
    return nil if activity.type.blank?

    case activity.type.downcase
    when 'pinnednote'
      'Note'
    when 'quizactivity'
      'Quiz'
    else
      activity.type.titlecase
    end
  end

  def icon_for(activity)
    case activity.type.to_s.downcase
    when "problem", "challenge"
      'fa fa-hammer'
    when "assignment"
      if activity.evaluates_code?
        'fa fa-hammer'
      else
        'fa fa-code'
      end
    when "task"
      'fa fa-bolt'
    when "pinnednote"
      'fa fa-sticky-note'
    when "lectureplan", "breakout"
      'fa fa-users'
    when "homework"
      'far fa-moon'
    when "survey"
      'fa fa-list-alt'
    when "video"
      'fa fa-video'
    when 'reading'
      'fa fa-book'
    when "test"
      'fa fa-gavel'
    when "quizactivity"
      'fa fa-question'
    when "walkthrough"
      'fa fa-walking'
    end
  end

  def activity_type_options
    %w[
      Assignment
      Task
      LecturePlan
      Homework
      Video
      Test
    ]
  end

  def activity_title_background_style(activity)
    if activity_has_bg_image?(activity)
      style = []
      image_url = activity.background_image_url || activity.section&.background_image_url
      darkness = activity.background_image_darkness || activity.section&.background_image_darkness
      style << "linear-gradient(rgba(0, 0, 0, #{darkness}), rgba(0, 0, 0, #{darkness}))" if darkness.present?
      style << "url('#{image_url}')"
      "background-image: #{style.join(', ')};"
    end
  end

  def activity_title_background_class(activity)
    if activity_has_bg_image?(activity)
      "bg"
    else
      "colored"
    end
  end

  def activity_has_bg_image?(activity)
    activity.background_image_url? || activity.section&.background_image_url?
  end

end
