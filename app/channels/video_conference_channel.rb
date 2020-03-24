class VideoConferenceChannel < ApplicationCable::Channel

  def subscribed
    stream_from channel_name
  end

  def update_conference(_status, video_conference_id)
    video_conference = VideoConference.find(video_conference_id)
    ActionCable.server.broadcast channel_name, type: "VideoConferenceUpdate", object: VideoConferenceSerializer.new(video_conference).as_json
  end

  def self.update_conference(video_conference, channel)
    ActionCable.server.broadcast channel, type: "VideoConferenceUpdate", object: VideoConferenceSerializer.new(video_conference).as_json
  end

  def self.channel_name_from_cohort(cohort)
    "video-conferences-#{cohort.name}"
  end

  protected

  def channel_name
    VideoConferenceChannel.channel_name_from_cohort(cohort)
  end

end
