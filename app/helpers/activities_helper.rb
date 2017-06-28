module ActivitiesHelper

  def get_activity_path(activity)
    if activity.prep?
      prep_activity_path(:prep, activity)
    else
      day_activity_path(activity.day, activity)
    end
  end

  def assistance_activities_grouped_by_day_for_select
    grouped_options_for_select(
      current_user.visible_bootcamp_activities.assistance_worthy.pluck(:name, :day, :id).group_by {|d| d[1] },
      @activity.try(:id)
    )
  end

  def bootcamp_activities_uuid_for_select
    grouped_options_for_select(
      current_user.visible_bootcamp_activities.assistance_worthy.pluck(:name, :day, :uuid).group_by {|d| d[1] },
    )
  end

  def prep_activities_uuid_for_select
    grouped_options_for_select(
      Activity.prep.assistance_worthy.joins(:section).pluck(:name, "sections.name", :uuid).group_by {|d| d[1] },
    )
  end

  def teacher_activities_uuid_for_select
    grouped_options_for_select(
      Activity.teacher.assistance_worthy.joins(:section).pluck(:name, "sections.name", :uuid).group_by {|d| d[1] },
    )
  end

  def markdown(content, renderer=CompassMarkdownRenderer)
    return '' if content.nil?
    options = {
      autolink: true,
      space_after_headers: true,
      fenced_code_blocks: true,
      tables: true
    }
    @markdown ||= Redcarpet::Markdown.new(renderer, options)
    @markdown.render(content)
  end

  def duration_in_hours(duration)
    number_with_precision (duration.to_f / 60), precision: 2, strip_insignificant_zeros: true
  end

  def descriptive_activity_name(activity)
    name = activity.name
    name << ' (Stretch)' if activity.stretch?
    name << ' [Archived]' if activity.archived?
    name
  end

  def duration activity
    if @program.display_exact_activity_duration? && activity.display_duration?
      duration_range activity
    else
      vague_duration activity
    end
  end

  def vague_duration activity
    duration = activity.duration.to_i
    vague_duration = if duration > 0 && duration <= 30
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
    "<br>#{vague_duration}<br>".html_safe
  end

  def duration_range(activity)
    durations = activity.duration_range
    if durations.size == 2 && durations[1] - durations[0] > 15
      "#{round5(durations[0])}m<br>to<br>#{round5(durations[1])}m".html_safe
    else
      "<br>#{round5([durations.first, durations.last].max)}m<br>".html_safe
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
    when "assignment"
      if activity.evaluates_code?
        'fa fa-gears'
      elsif activity.allow_submissions?
        'fa fa-github'
      else
        'fa fa-code'
      end
    when "task"
      'fa fa-flash'
    when "pinnednote"
      'fa fa-sticky-note'
    when "lecture", "breakout"
      'fa fa-group'
    when "homework"
      'fa fa-moon-o'
    when "survey"
      'fa fa-list-alt'
    when "video"
      'fa fa-video-camera'
    when 'reading'
      'fa fa-book'
    when "test"
      'fa fa-gavel'
    when "quizactivity"
      'fa fa-question'
    end
  end

  def activity_type_options
    [
      'Assignment',
      'Task',
      'Lecture',
      'Homework',
      'Video',
      'Test'
    ]
  end

end
