module ActivitiesHelper

  def get_activity_path(activity)
    if activity.prep?
      prep_activity_path(:prep, activity)
    else
      day_activity_path(activity.day, activity)
    end
  end

  def markdown(content)
    return '' if content.nil?
    options = {
      autolink: true,
      space_after_headers: true,
      fenced_code_blocks: true,
      tables: true
    }
    @markdown ||= Redcarpet::Markdown.new(CompassMarkdownRenderer, options)
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
    duration = activity.duration.to_i
    if duration > 0 && duration <= 60
      'Short'
    elsif duration >= 180
      'Long'
    elsif duration > 60 && duration < 180
      'Medium'
    else # 0 / nil
      'Unknown'
    end
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

  def get_activity_presenter_class(section)
    if section
      "#{section.class}ActivityPresenter".constantize
    end
  end
end
