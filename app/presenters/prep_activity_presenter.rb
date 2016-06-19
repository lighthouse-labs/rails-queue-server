class PrepActivityPresenter < ActivityPresenter

  def render_sidenav

  end

  private

  def edit_button_path
    edit_prep_activity_path(activity.section, activity)
  end

end

