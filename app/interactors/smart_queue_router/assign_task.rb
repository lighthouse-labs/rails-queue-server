class SmartQueueRouter::AssignTask

  include Interactor

  before do
    @teachers = context.teachers
    @assistance_request = context.assistance_request
    @desired_task_assignment = context.desired_task_assignment
  end

  def call
    @teachers.sort_by { |_k, teacher| teacher[:routing_score] }.reverse

    assigned_tasks = []
    @teachers.each do |_k, teacher|
      task = @assistance_request.assign_task(teacher[:object])
      next unless task

      assigned_tasks.push({ task: task, shared: false })
      if teacher[:routing_score] < -100
        # teacher's queue is greater than max queue size
        # notify EM that queue size was forced to be larget than max size
      end
      break if assigned_tasks.length >= @desired_task_assignment
    end
    context.fail! if assigned_tasks.empty?
    if assigned_tasks.length < @desired_task_assignment
      # notify em that there is not enough on duty teachers to assign task to
      # desired number of queues
    end
    context.assigned_tasks = assigned_tasks
  end

end
