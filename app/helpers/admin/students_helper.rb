module Admin::StudentsHelper

  def completed_registration?(student)
    student.completed_registration ? "YES" : "NO"
  end

  def prep_time_spent(minutes)
    if minutes <= 60
      "#{minutes} mins"
    else
      "#{(minutes / 60.0).round(2)} hours"
    end
  end

end
