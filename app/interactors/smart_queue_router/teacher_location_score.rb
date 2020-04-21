class SmartQueueRouter::TeacherLocationScore

  include Interactor

  before do
    @teachers = context.teachers
    @max_queue_size = context.max_queue_size
    @task_penalty = context.task_penalty
    @assistance_penalty = context.assistance_penalty
    @evaluation_penalty = context.evaluation_penalty
    @tech_interview_penalty = context.tech_interview_penalty
  end

  def call
    @teachers.each do |id, teacher|
      teacher[:routing_score] ||= 0
      teacher[:routing_score] += teacher[:object].queue_tasks.open_tasks.count <= @max_queue_size ? teacher[:object].queue_tasks.open_tasks.count * @task_penalty : -500
      teacher[:routing_score] += teacher[:object].assistances.currently_active.count * @assistance_penalty
      teacher[:routing_score] += teacher[:object].evaluations.in_progress_evaluations.count * @evaluation_penalty
      teacher[:routing_score] += teacher[:object].tech_interviews.in_progress.count * @tech_interview_penalty
    end

    puts 'availabilioty~~~~~~~~~~~~~~~~~~~'
    puts @teachers.inspect
    puts '~~~~~~~~~~~~~~~~~~~'       
  end

end
