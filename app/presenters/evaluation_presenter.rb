class EvaluationPresenter < BasePresenter

  presents :evaluation

  def student_info
    content_tag(:div, render('shared/student_info', student: evaluation.student, show_cohort: true), class: 'student-info')
  end

  def project_status
    result = render('projects/student_project_status', project_evaluation: evaluation)
    result += tag('br')
    result += content_tag(:small, "#{time_ago_in_words(evaluation.updated_at)} ago")
    content_tag(:div, result)
  end

  def teacher_info
    if evaluation && evaluation.teacher
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
    if include_link
      result = project_name
      result += tag('br')
    end
    result += view_button if evaluation
    result += nbsp_escape_false
    result += state_marking_button
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
      :class         => 'badge ' + project_score_label_class(value),
      :title         => title,
      :"data-toggle" => 'tooltip'
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
      unless index + 1 == evaluation.result.count
        result += content_tag(:small, nbsp_escape_false + "+ ")
      end
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
