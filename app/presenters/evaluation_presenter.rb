class EvaluationPresenter < BasePresenter

  presents :evaluation

  def student_info
    content_tag(:div, render('shared/student_info', student: evaluation.student, show_cohort: true), class: 'student-info') if evaluation.student
  end

  def project_status
    result = render('projects/student_project_status', project_evaluation: evaluation)
    result += tag('br')
    if evaluation.completed_at?
      if evaluation&.student&.cohort
        curriculum_day = CurriculumDay.new(evaluation.completed_at.to_date, evaluation.student.cohort).to_s
        completed = evaluation.completion_day
        result += content_tag(:span, curriculum_day, class: 'badge badge-success', 'data-toggle': 'tooltip', 'title': "#{time_ago_in_words(evaluation.completed_at)} ago")
        result += tag('br')
      end
      result += content_tag(:small, completed)
    end

    content_tag(:div, result)
  end

  def date_submitted
    result = ""
    if evaluation&.student&.cohort
      days_late = evaluation.days_late
      curriculum_day = CurriculumDay.new(evaluation.created_at.to_date, evaluation.student.cohort).to_s
      result += if days_late > 0
                  content_tag(:span, curriculum_day, class: 'badge badge-danger', 'data-toggle': 'tooltip', 'title': "#{days_late.to_i} days late")
                elsif days_late < 0
                  content_tag(:span, curriculum_day, class: 'badge badge-success', 'data-toggle': 'tooltip', 'title': "#{days_late.to_i.abs} days early")
                end
      result += tag('br')
    end
    result += content_tag(:small, evaluation.created_at.to_date)
    result.html_safe
  end

  def teacher_info
    if evaluation&.teacher
      teacher_info = teacher_avatar
      teacher_info += teacher_name
      teacher_info += tag("br")
      teacher_info += teacher_location
      content_tag(:div, teacher_info, class: 'teacher-info')
    end
  end

  def teacher_avatar
    link_to teacher_path(evaluation.teacher) do
      image_tag evaluation.teacher.avatar_url, class: 'avatar'
    end
  end

  def teacher_name
    link_to evaluation.teacher.full_name, teacher_path(evaluation.teacher)
  end

  def teacher_location
    content_tag(:span, evaluation.teacher.location.name, class: 'badge badge-primary')
  end

  def project(include_link = nil)
    result = tag("div")
    result += view_button if evaluation
    result += nbsp_escape_false
    result += state_marking_button
    if include_link
      result += tag('br')
      result += tag('small')
      result += project_name
    end
    content_tag(:div, result)
  end

  def project_name
    link_to evaluation.project.name, evaluation.project
  end

  def nbsp_escape_false
    content_tag(:span, '&nbsp;', nil, false)
  end

  def view_button
    link_to 'View', project_evaluation_path(evaluation.project, evaluation), class: 'btn btn-info btn-xs'
  end

  def state_marking_button
    if evaluation.in_state?(:pending)
      start_marking_button
    elsif evaluation.in_state?(:in_progress) && evaluation.teacher == current_user
      continue_marking_button
    end
  end

  def start_marking_button
    link_to "Start Marking", start_marking_project_evaluation_path(evaluation.project, evaluation), method: :put, class: 'btn btn-primary btn-xs'
  end

  def continue_marking_button
    link_to "Continue Marking", edit_project_evaluation_path(evaluation.project, evaluation), class: 'btn btn-primary btn-xs'
  end

  def eval_options_hash(title, value)
    {
      class:         'badge ' + project_score_label_class(value),
      title:         title,
      "data-toggle": 'tooltip'
    }
  end

  def stats
    if evaluation && (evaluation.status == "Rejected" || evaluation.status == "Accepted")
      score = evaluation.final_score? ? evaluation.final_score.to_s : '?'
      options = eval_options_hash('Final Score', score)
      value = content_tag(:strong, score)
      result = content_tag(:span, value, options)
      if evaluation.result
        result += content_tag(:span, nbsp_escape_false + "= ")
        result += evaluation_results_stats
      end
      result += queue_stats
    end
    result
  end

  def evaluation_results_stats
    result = tag(:span)
    evaluation.result.each_with_index do |(res, detail), index|
      options = eval_options_hash(res.humanize, detail['score'])
      value = content_tag(:strong, detail['score'].to_s)
      result += content_tag(:span, value, options, false)
      result += content_tag(:small, nbsp_escape_false + "+ ") unless index + 1 == evaluation.result.count
    end
    result
  end

  def queue_stats
    result = tag('br')
    result += content_tag(:span, "#{evaluation.time_in_queue / 60}m in queue")
    if evaluation.completed_at
      result += tag('br')
      result += content_tag(:span, "#{evaluation.duration / 60}m long")
    end
    result
  end

end
