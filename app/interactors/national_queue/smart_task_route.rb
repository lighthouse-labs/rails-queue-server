class NationalQueue::SmartTaskRoute

  include Interactor

  before do
    @assistance_request = context.assistance_request
    @assistor = context.assistor
  end

  def call
    updates = []
    if !@assistance_request.canceled_at? && @assistance_request.queue_tasks.empty?
      if @assistance_request.request['route']
        smart_task_result = SmartQueueRouter::RouteTask.call(
          assistance_request: @assistance_request
        )
        context.fail! unless smart_task_result.success?

        updates = smart_task_result.assigned_tasks
      else
        task = @assistance_request.assign_task(@assistor)
        if @assistor
          @assistance_request.assign_task(nil)
          context.fail!(error: 'Failed creating assistance.') unless @assistance_request.start_assistance(@assistor)
        end
        context.fail!(error: 'Failed creating queue task.') unless task
        updates.push({ task: task, shared: true })
      end
    else
      # rescore pending AR's
      smart_task_result = SmartQueueRouter::UpdateQueues.call(
        assistance_request: @assistance_request
      )
      updates += smart_task_result.assigned_tasks
      @assistance_request.queue_tasks.each do |task|
        updates.push({ task: task, shared: public_task(task) })
      end
    end
    context.updates = updates
  end

  def public_task(task)
    (task.assistor_uid == @assistor&.uid) || task.assistor_uid.nil?
  end

end
