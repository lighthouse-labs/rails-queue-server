class ProjectActivityPresenter < ActivityPresenter
  def render_sidenav
    content_for :project_nav do
      render('shared/menus/project_side_menu', project: activity.section)
    end
  end

  def breadcrumb
    result = "<ol class='breadcrumb'><li>#{link_to("Projects", projects_path)}</li>"
    result += "<li>#{link_to activity.section.name, activity.section}</li>"
    result += "<li>#{link_to activity.name, day_activity_path(activity.day, activity)}</li></ol>"
  end

  private
  def edit_button_path
    edit_project_activity_path(activity.day, activity)
  end
end
