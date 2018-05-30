module LecturesHelper

  def lecture_thumbnail(lecture)
    if lecture.youtube_url?
      youtube_lecture_thumbnail lecture.youtube_url
    else
      no_video_lecture_thumbnail
    end
  end

  def youtube_lecture_thumbnail(youtube_url)
    image_tag("https://img.youtube.com/vi/0WYwaXS0CR0/2.jpg", style: 'width: 100%')
  end

  def no_video_lecture_thumbnail
    image_tag('no-video-thumbnail.jpg', style: 'width: 100%')
  end

end