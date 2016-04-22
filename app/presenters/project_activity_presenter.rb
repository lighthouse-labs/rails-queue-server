class ProjectActivityPresenter < ActivityPresenter
  def render_sidenav
    content_for :project_nav do
      render('shared/menus/project_side_menu', project: activity.section)
    end
  end

  private
  def edit_button_path
    edit_project_activity_path(activity.day, activity)
  end
end
