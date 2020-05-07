class SmartQueueRouter::ReassignQueue

  include Interactor

  before do
    @assistor = context.assistor
    @settings = context.settings || {}
  end

  def call
    assigned_tasks = []
    assigned_assistance_requests = []
    if @assistor.on_duty?
      context.fail! unless @assistor.toggle_duty
    end
    @open_tasks = @assistor.queue_tasks.open_tasks
    @open_tasks.each do |task|
      score_result = SmartQueueRouter::ScoreForAr.call({
        assistance_request: task.assistance_request,
        settings:           @settings
      })
      break unless score_result.success?

      assigned_assistance_requests.push(task.assistance_request)
      desired_task_assignment = @settings[:desired_task_assignment] || 5

      teachers = score_result.teachers.sort_by { |_k, teacher| teacher[:routing_score] }.reverse.first desired_task_assignment

      teachers.each do |_k, teacher|
        next if teacher[:object].assigned_ar?(task.assistance_request)

        task = task.assistance_request.assign_task(teacher[:object])
        next unless task

        assigned_tasks.push({ task: task, shared: false })
        if teacher[:routing_score] < -100
          # teacher's queue is greater than max queue size
          # notify EM that queue size was forced to be larget than max size
        end
      end
    end
    context.assigned_assistance_requests = assigned_assistance_requests
    context.assigned_tasks = assigned_tasks
  end

end
