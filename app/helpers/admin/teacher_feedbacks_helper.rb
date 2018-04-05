module Admin::TeacherFeedbacksHelper
  def avg_ratings(ratings)
    avg = ratings.inject(0){|sum,feedback| sum + feedback.rating}
    (avg.to_f / ratings.length.to_f).round(2)
  end

  def avg_ratings_or_na(ratings, max)
    if ratings.any?
      "#{avg_ratings(ratings)} / #{max}"
    else
      "N/A"
    end
  end
end
