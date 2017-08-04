class ActivityPresenter < BasePresenter

  presents :activity

  def name
    result = ""
    result += content_tag(:i, nil, class: icon_for(activity))
    result += " #{activity.name} #{'(Stretch) ' if activity.stretch?}"
    result += content_tag(:small, activity_type(activity)) if activity.type?

    if project?
      result += "<br><small>".html_safe
      result += link_to("Project: #{activity.section.name}", activity.section).html_safe
      result += "</small>".html_safe
    elsif prep?
      result += "<br><small>#{activity.section.name}</small>".html_safe
    end

    result.html_safe
  end

  def render_sidenav
    if prep?
      content_for :side_nav do
        render('shared/menus/sections_side_menu', title: 'Prep Work', sections: preps)
      end
    elsif teacher_resources?
      content_for :side_nav do
        render('shared/menus/sections_side_menu', title: 'Training', sections: teacher_resources)
      end
    elsif bootcamp?
      content_for :side_nav do
        render('layouts/side_nav')
      end
    end

    # append project specific content if it's part of a project.
    if project?
      content_for :side_nav do
        render('shared/menus/project_side_menu', project: activity.section)
      end
    end
  end

  def previous_button
    if activity.previous
      content_tag :div, class: 'previous-activity' do
        (
          content_tag(:label, 'Previous:') +
          content_tag(:i, nil, class: icon_for(activity.previous)) + ' ' +
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
          content_tag(:i, nil, class: icon_for(activity.next)) + ' ' +
          link_to(descriptive_activity_name(activity.next), get_activity_path(activity.next))
        ).html_safe
      end
    end
  end

  def submissions_text
    activity.allow_submissions? ? "Submissions" : "Completions"
  end

  def submission_form
    if allow_completion?
      if activity.evaluates_code?
        render "code_activity_submission_form"
      else
        render "activity_submission_form"
      end
    end
  end

  def details_button
    link_to 'Details', details_button_path, class: 'btn btn-edit'
  end

  def display_outcomes
    render "outcomes", activity: activity if activity.item_outcomes.any?
  end

  def before_instructions
    # overwritten
    render 'code_evaluation_info' if activity.evaluates_code?
  end

  def after_instructions
    # overwritten
  end

  protected

  def project?
    activity.project?
  end

  def prep?
    activity.prep?
  end

  def teacher_resources?
    activity.teachers_only?
  end

  def bootcamp?
    activity.bootcamp?
  end

  def details_button_path
    if prep?
      edit_prep_activity_path(activity.section, activity)
    elsif project?
      edit_project_activity_path(activity.day, activity)
    elsif activity.day?
      edit_day_activity_path(activity.day, activity)
    end
  end

  private

  def allow_completion?
    !activity.is_a?(QuizActivity)
  end

end
