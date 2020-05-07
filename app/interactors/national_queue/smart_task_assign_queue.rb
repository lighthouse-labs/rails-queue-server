class NationalQueue::SmartTaskAssignQueue

  include Interactor

  before do
    @assistor = context.assistor
  end

  def call
    updates = []
    unless @assistor.on_duty?
      context.fail! unless @assistor.toggle_duty
    end
    smart_task_result = SmartQueueRouter::AssignQueue.call(
      assistor: @assistor
    )
    context.fail! unless smart_task_result.success?

    smart_task_result.assigned_tasks.each do |assigned_task|
      NationalQueue::BroadcastStudentQueueUpdate.call(assistance_request: assigned_task[:task].assistance_request)
    end

    updates = smart_task_result.assigned_tasks
    context.updates = updates
  end

end
