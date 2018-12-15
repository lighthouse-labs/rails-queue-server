class ConsolidateActivityFeedback < ActiveRecord::Migration[5.0]
  def up
    change_column :activity_feedbacks, :rating, :float
    ActivityFeedback.reset_column_information

    say "Consolodating feedback"
    Activity.active.each do |activity|
      print "#{activity.id}: "

      activity.activity_feedbacks.group(:user_id).having('count(id) > 1').select(:user_id).reorder(nil).pluck(:user_id).each do |user_id|
        fix_feedback_for(activity, user_id)
      end
      puts " :)"
    end
  end

  # count before: 110900
  # count after:  82792
  # ActivityFeedback.find 64234
  # ActivityFeedback.find 71500

  def down
    say "Can't do it. No need to do it. Okay to skip"
  end

  private

  def fix_feedback_for(activity, user_id)
    total_rating = 0
    count_ratings = 0
    final_detail = []
    feedbacks = []

    activity.activity_feedbacks.where(user_id: user_id).reorder(id: :asc).each do |feedback|
      feedbacks.push feedback
      final_detail.push feedback.detail if feedback.detail?
      if feedback.rating?
        count_ratings += 1
        total_rating += feedback.rating
      end
    end

    avg_rating = count_ratings > 0 ? (total_rating.to_f / count_ratings).round(2) : nil

    attrs = {
      rating: avg_rating,
      detail: final_detail.join("\n-=-=-=-=-=-=-=-=-\n"),
    }
    # puts "#{feedbacks.last.id}: #{attrs.inspect}"
    feedbacks.last.update_columns(attrs)

    feedbacks[0..feedbacks.length-2].each(&:destroy)
    print "[#{feedbacks.size-1}]"
  end
end
