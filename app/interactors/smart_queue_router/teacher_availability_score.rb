class SmartQueueRouter::TeacherAvailabilityScore

  include Interactor

  before do
    @teachers = context.teachers
    @max_queue_size = context.max_queue_size
    @active_task_weight = context.active_task_weight
    @active_assistance_weight = context.active_assistance_weight
    @active_evaluation_weight = context.active_evaluation_weight
    @active_tech_interview_weight = context.active_tech_interview_weight
  end

  def call
    @teachers.each do |_uid, teacher|
      score = normalize(teacher[:object].queue_tasks.pending.count) * @active_task_weight
      # do this programatically so scoring buckets can be customized
      score += normalize(teacher[:object].teaching_assistances.in_progress.for_resource('Activity').count) * @active_assistance_weight
      score += normalize(teacher[:object].teaching_assistances.in_progress.for_resource('Evaluation').count) * @active_evaluation_weight
      score += normalize(teacher[:object].teaching_assistances.in_progress.for_resource('TechInterview').count) * @active_tech_interview_weight
      teacher[:routing_score].total += score
      teacher[:routing_score].summary['TeacherAvailabilityScore'] = score
    end
  end

  private

  def normalize(quantity)
    half_point = @max_queue_size / 2
    (-1 / (quantity / half_point + 1) + 1) * -1
  end

end
