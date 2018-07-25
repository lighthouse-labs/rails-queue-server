class LecturePresenter < BasePresenter

  presents :lecture

  def youtube_code
    YouTubeAddy.extract_video_id(lecture.youtube_url)
  end

end
