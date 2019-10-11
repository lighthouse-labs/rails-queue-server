module ProjectsHelper

  def project_title_background_style(project)
    if project.background_image_url?
      image_url = project.background_image_url
      darkness = project.background_image_darkness
      activity_or_project_background_image_css(image_url, darkness)
    end
  end

end
