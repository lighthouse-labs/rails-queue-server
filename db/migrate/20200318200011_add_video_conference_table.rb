class AddVideoConferenceTable < ActiveRecord::Migration[5.0]
  def change
    create_table    :video_conferences do |t|
      t.datetime    :start_time
      t.integer     :duration
      t.string      :status
      t.string      :zoom_meeting_id
      t.string      :start_url
      t.string      :join_url
      t.references  :activity, foreign_key: true
      t.references  :cohort, foreign_key: true
      t.references  :user, foreign_key: true
    end
  end
end
