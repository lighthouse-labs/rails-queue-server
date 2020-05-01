class NationalQueue::SmartTaskRoute

  include Interactor

  before do
    @assistance_request = context.assistance_request
    @assistor = context.assistor
  end

  def call
    updates = []
    if !@assistance_request.canceled_at? && @assistance_request.queue_tasks.empty?
      smart_task_result = SmartQueueRouter::RouteTask.call(
        assistance_request: @assistance_request
      )
      context.fail! unless smart_task_result.success?

      updates = smart_task_result.assigned_tasks
    else
      # later may re assign tasks
      @assistance_request.queue_tasks.each do |task|
        updates.push({ task: task, shared: public_task(task) })
      end
    end
    context.updates = updates
  end

  def public_task(task)
    task.user.id == @assistor.id
  end

end
