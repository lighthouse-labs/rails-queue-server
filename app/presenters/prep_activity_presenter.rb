class PrepActivityPresenter < ActivityPresenter

  def name
    result = super
    result += "<br><small>#{activity.section.name}</small>".html_safe
    result
  end

  def render_sidenav
    content_for :side_nav do
      render('shared/menus/prep_side_menu')
    end
  end

  private

  def edit_button_path
    edit_prep_activity_path(activity.section, activity)
  end

end

