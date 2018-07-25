module Admin::StudentsHelper

  def completed_registration?(student)
    student.completed_registration ? "YES" : "NO"
  end

  def prep_time_spent(minutes)
    if minutes <= 60
      "#{minutes} mins"
    else
      "#{(minutes / 60.0).round(1)} hours"
    end
  end

  def day_placeholder(user)
    user.use_double_digit_week? ? "wxxdx or wxxe" : "wxdx or wxe"
  end

  def status(student)
    if student.deactivated?
      '<span class="badge badge-danger">Deactivated</span>'
    elsif student.active_student?
      '<span class="badge badge-success">Enrolled</span>'
    elsif student.enrolled_and_prepping?
      '<span class="badge badge-secondary">Upcoming</span>'
    elsif student.alumni?
      '<span class="badge badge-info">Graduated</span>'
    end
  end

end
