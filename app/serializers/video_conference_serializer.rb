class VideoConferenceSerializer < ActiveModel::Serializer

  format_keys :lower_camel

  attributes  :start_time,
              :duration,
              :status,
              :zoom_meeting_id,
              :start_url,
              :join_url,
              :activity_id,
              :cohort_id,
              :user_id

end