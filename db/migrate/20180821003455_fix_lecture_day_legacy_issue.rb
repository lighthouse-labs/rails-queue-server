class FixLectureDayLegacyIssue < ActiveRecord::Migration[5.0]
  def up
    # Go through all single digit week patterns and make them double digit
    # Examples:
    #   w7d2  => w07d2
    #   w4e   => w04e (there should be no weekend lectures, but just in case ;)
    #   w06d3 => w06d3
    Lecture.all.find_each(batch_size: 100) do |lecture|
      # All lectures should have their `day` set (not nil), but just being extra safe
      if lecture.day?
        # I could do the if and elsif in one go but it would be more complicated to read/undertand & write
        day = nil
        if m = lecture.day.match(/w(\d)d(\d)/)
          day = "w0#{m[1]}d#{m[2]}"
          say "lecture #{lecture.id}: #{m[0]} => #{day}"
        elsif lecture.day.match(/w(\d)e/)
          day = "w0#{m[1]}e"
          say "lecture #{lecture.id}: #{m[0]} => #{day}"
        end
        lecture.update_columns(day: day) if day
      end
    end
  end
  def down
    say "No structural changes; hard to reverse so skipping rollback (not worth it!)"
  end
end
