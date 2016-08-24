class ActivityStatsUpdater

  def run
    Activity.active.find_each(batch_size: 100) do |activity|
      stats = {}
      if activity.activity_submissions.where.not(time_spent: nil).any?
        stats[:average_time_spent] = activity.activity_submissions.where.not(time_spent: nil).average('time_spent::float').round(0).to_i
      end
      if activity.activity_feedbacks.where.not(rating: nil).any?
        stats[:average_rating] = activity.activity_feedbacks.where.not(rating: nil).average('rating::float').round(3)
      end
      if stats.any?
        puts "#{activity.id}: #{stats[:average_rating]}/5.0, #{stats[:average_time_spent]}m"
        Activity.where(id: activity.id).update_all(stats)
      end
    end
  end

end