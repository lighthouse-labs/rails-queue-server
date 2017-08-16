class ProjectPresenter < BasePresenter

  presents :project

  def student_info(student)
    content_tag(:div, render('shared/student_info', student: student), class: 'student-info')
  end

  def student_project_status
    project_week = project.end_day[1].to_i
    result = if cohort.week > project_week
               content_tag(:span, 'Overdue', class: 'label label-danger')
             elsif cohort.week == project_week
               content_tag(:span, 'This Week', class: 'label label-info')
             elsif cohort.week + 1 == project_week
               content_tag(:span, 'Next Week', class: 'label label-info')
             else
               content_tag(:span, 'Pending', class: 'label label-info')
             end
    result
  end

end
