class CopyRecordingsAndAmsIntoLectures < ActiveRecord::Migration[5.0]

  def up
    cnt = 0

    ActivityMessage.order(id: :desc).find_each(batch_size: 100) do |msg|
      if rec = find_rec(msg)
        if move_over(msg, rec)
          cnt += 1
          say ":) Successfully Moved over #{msg.id} and #{rec.id}"
          msg.update_columns(archived: true)
          rec.update_columns(archived: true)
        else
          say "X Failed to move over #{msg.id} for activity #{msg.activity_id}. "
        end
      end
    end

    say "#{cnt} Lecture records created."
  end

  def down
    ActivityMessage.update_all(archived: nil)
    Recording.update_all(archived: nil)
    Lecture.delete_all
  end

  private

  def move_over(msg, rec)
    attrs = {
      presenter: msg.user,
      cohort: msg.cohort,
      activity: msg.activity,
      presenter_name: rec.presenter_name,
      file_type: rec.file_type,
      subject: msg.subject,
      body: scrubbed_body(msg),
      day:  msg.day,
      teacher_notes: msg.teacher_notes
    }
    if rec.file_name? && rec.file_name.starts_with?('https://')
      attrs[:youtube_url] = rec.file_name
    else
      attrs[:file_name] = rec.file_name
    end
    l = Lecture.new(attrs)
    l.save
  end

  # Initially we thought we'd have to use date too, but actually there should only be one recording per activity per cohort
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
