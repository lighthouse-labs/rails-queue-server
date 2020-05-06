class NationalQueue::SmartTaskReassignQueue

  include Interactor

  before do
    @assistor = context.assistor
  end

  def call
    updates = []
    context.fail! unless @assistor.toggle_duty
    smart_task_result = SmartQueueRouter::ReassignQueue.call(
      assistor: @assistor
    )
    context.fail! unless smart_task_result.success?

    smart_task_result.assigned_assistance_requests.each do |assistance_request|
      NationalQueue::BroadcastStudentQueueUpdate.call( assistance_request: assistance_request)
    end

    updates = smart_task_result.assigned_tasks
    context.updates = updates
  end

end
