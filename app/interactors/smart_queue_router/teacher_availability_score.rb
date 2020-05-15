class SmartQueueRouter::TeacherAvailabilityScore

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
    puts 'availability ++++++++++++++++++++++++++++++'


    @teachers.each do |_uid, teacher|
      teacher[:routing_score] ||= 0
      teacher[:routing_score] += teacher[:object].queue_tasks.pending.count * @task_penalty
      # do this programatically so scoring buckets can be customized
      teacher[:routing_score] += teacher[:object].teaching_assistances.in_progress.for_resource('Activity').count * @assistance_penalty
      teacher[:routing_score] += teacher[:object].teaching_assistances.in_progress.for_resource('Evaluation').count * @evaluation_penalty
      teacher[:routing_score] += teacher[:object].teaching_assistances.in_progress.for_resource('TechInterview').count * @tech_interview_penalty
    end
  end

end
