class ActivityPresenter < BasePresenter

  presents :activity

  def name
    result = ""
    result += content_tag(:i, nil, class: icon_for(activity))
    result += " #{activity.name} #{'(Stretch) ' if stretch?}"
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
    if workbook
      content_for :side_nav do
        render 'workbooks/side_menu'
      end
    elsif prep?
      content_for :side_nav do
        render('shared/menus/sections_side_menu', title: 'Prep Work', sections: preps)
      end
    elsif teacher_resources?
      content_for :side_nav do
        render('shared/menus/sections_side_menu', title: 'Training', sections: teacher_resources)
      end
    elsif bootcamp?
      content_for :side_nav do
        render('shared/menus/bootcamp_day_menu')
      end
    end

    # append project specific content if it's part of a project.
    # if project?
    #   content_for :side_nav do
    #     render('shared/menus/project_side_menu', project: activity.section)
    #   end
    # end
  end

  def submissions_text
    activity.allow_submissions? ? "Submissions" : "Completions #{cohort.completed_activity(activity)}/#{cohort.students.active.size}"
  end

  def submission_form
    if allow_completion?
      next_activity = next_activity(workbook)
      next_path = get_activity_path(next_activity, workbook, activity)
      if activity.evaluates_code?
        render "code_activity_submission_form", next_path: next_path
      else
        render "activity_submission_form", next_path: next_path
      end
    end
  end

  def details_link
    link_to 'Details', details_button_path, style: 'color: white'
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

  def next_activity(workbook = nil)
    workbook ? workbook.next_activity(activity) : activity.next
  end

  def previous_activity(workbook = nil)
    workbook ? workbook.previous_activity(activity) : activity.previous
  end

  protected

  def stretch?
    if workbook
      workbook.stretch_activity?(activity)
    else
      activity.stretch?
    end
  end

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

  def workbook
    @options[:workbook]
  end

  def allow_completion?
    !activity.is_a?(QuizActivity)
  end

end
