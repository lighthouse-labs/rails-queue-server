class PrepActivityPresenter < ActivityPresenter
  def render_sidenav
    content_for :prep_nav do
      render('shared/menus/prep_side_menu')
    end
  end

  private
  def edit_button_path
    edit_day_activity_path(activity.day, activity)
  end
end

