module ProjectsHelper

  def project_title_background_style(project)
    if project.background_image_url?
      style = []
      image_url = project.background_image_url
      darkness = project.background_image_darkness
      if darkness.present?
        style << "linear-gradient(rgba(0, 0, 0, #{darkness}), rgba(0, 0, 0, #{darkness}))"
      end
      style << "url('#{image_url}')"
      "background-image: #{style.join(', ')};"
    end
  end

end
