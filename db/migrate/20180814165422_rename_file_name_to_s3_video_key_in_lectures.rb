class RenameFileNameToS3VideoKeyInLectures < ActiveRecord::Migration[5.0]
  def up
    rename_column :lectures, :file_name, :s3_video_key

    count = 0

    ActivityMessage.order(id: :desc).find_each(batch_size: 100) do |msg|
      rec = find_rec(msg)
      if rec&.is_s3? && move_over(msg, rec)
        count += 1
        say ":) Successfully Moved over #{msg.id} (recording: #{rec&.id})"
        msg.update_columns(archived: true)
        rec.update_columns(archived: true) if rec
      else
        say "X Failed to move over #{msg.id} for activity #{msg.activity_id}. "
      end
    end
    say "#{Recording.is_s3.count} S3 recordings encountered."
    say "#{count} Lecture records created."
  end

  def down
    Lecture.video_is_s3.delete_all
    rename_column :lectures, :s3_video_key, :file_name
  end

  private

  def move_over(msg, rec = nil)
    attrs = {
      legacy: true,
      presenter: msg.user,
      cohort: msg.cohort,
      activity: msg.activity,
      file_type: rec&.file_type,
      subject: msg.subject,
      body: scrubbed_body(msg),
      day:  msg.day,
      teacher_notes: msg.teacher_notes,
      created_at: msg.created_at,
      updated_at: msg.updated_at,
      s3_video_key: rec&.file_name
    }
    l = Lecture.new(attrs)
    l.save
  end

  def find_rec(msg)
    Recording.find_by(
      presenter_id: msg.user_id,
      cohort_id:    msg.cohort_id,
      activity_id:  msg.activity_id
    )
  end

    # match the final sentence which has a URL that shouldn't be in there
  # Eg: https://web.compass.lighthouselabs.ca/days/w04d1/activities/211
  # It's a reference back to the activity. Should be in the email template not in the body
  def scrubbed_body(msg)
    msg.body.gsub(/https\:\/\/[a-z\.\-]+compass\.lighthouselabs\.ca\/days\/w[0-9]+d[1-5]\/activities\/[0-9]+\Z/, '')
  end
end
