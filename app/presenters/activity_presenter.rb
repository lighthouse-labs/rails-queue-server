class ActivityPresenter < BasePresenter
  presents :activity

  def name
    result = ""
    result += content_tag(:i, nil, class: icon_for(activity))
    result += " #{activity.name} #{'(Stretch) ' if activity.stretch?}"
    result += content_tag(:small, activity_type(activity)) if activity.type?
    result.html_safe
  end

  def render_sidenav
    unless current_user.prepping? || current_user.prospect? || activity.prep?
      content_for :side_nav do
        render('layouts/side_nav')
      end
    end
  end

  def previous_button
    if activity.previous
      content_tag :div, class: 'previous-activity' do
        (
          content_tag(:label, 'Previous:') +
          link_to(descriptive_activity_name(activity.previous), get_activity_path(activity.previous))
        ).html_safe

      end
    end
  end

  def next_button
    if activity.next
      content_tag :div, class: 'next-activity' do
        (
          content_tag(:label, 'Next:') +
          link_to(descriptive_activity_name(activity.next), get_activity_path(activity.next))
        ).html_safe
      end
    end
  end

  def submissions_text
    activity.allow_submissions? ? "Submissions" : "Completions"
  end

  def submission_form
    render "activity_submission_form" if allow_completion?
  end

  def edit_button
    link_to 'Edit', edit_button_path, class: 'btn btn-edit'
  end

  def display_outcomes
    render "outcomes", activity: activity if activity.outcomes.present? || admin?
  end

  protected

  def edit_button_path
    edit_day_activity_path(activity.day, activity)
  end

  private

  # for now, if the activity evaluates code, dont show submission
  def allow_completion?
    !activity.evaluates_code? && !activity.is_a?(QuizActivity)
  end

end
