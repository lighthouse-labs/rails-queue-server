module Admin::EvaluationsHelper

  def project_score_label_class(val)
    l_score_label_class(val)
  end

  def total_marking_time(evaluations)
    total_seconds = evaluations.map{ |e| e.duration }.reduce(:+)
    seconds_to_formatted_time(total_seconds)
  end

  def average_marking_time(evaluations)
    average_seconds = evaluations.map{ |e| e.duration }.reduce(:+) / @evaluations.count
    seconds_to_formatted_time(average_seconds)
  end

end
