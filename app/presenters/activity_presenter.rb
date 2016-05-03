class ActivityPresenter < BasePresenter
  presents :activity

  delegate :name, to: :activity

  def render_sidenav
    unless current_user.prepping? || current_user.prospect? || activity.prep?
      content_for :side_nav do
        render('layouts/side_nav')
      end
    end
  end

  def previous_button
    if activity.previous
      link_to '&laquo; Previous'.html_safe, get_activity_path(activity.previous), class: 'btn btn-previous'
    end
  end

  def next_button
    if activity.next
      link_to 'Next &raquo;'.html_safe, get_activity_path(activity.next), class: 'btn btn-next'
    end
  end

  def submissions_text
    activity.allow_submissions? ? "Submissions" : "Completions"
  end

  def submission_form
    render "activity_submission_form"
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
end
