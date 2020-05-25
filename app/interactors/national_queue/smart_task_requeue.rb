class NationalQueue::SmartTaskRequeue

  include Interactor

  before do
    @user_uid = context.user_uid
  end

  def call
    updates = []
    context.assistor = @assistor = User.using(:web).find_by(uid: @user_uid)
    context.fail! unless @assistor
    context.fail! unless @assistor.toggle_duty
    if @assistor.on_duty?
      smart_task_result = SmartQueueRouter::AssignQueue.call(
        assistor: @assistor
      )
    else
      smart_task_result = SmartQueueRouter::ReassignQueue.call(
        assistor: @assistor
      )
    end
    context.fail! unless smart_task_result.success?

    smart_task_result.assigned_assistance_requests.each do |assistance_request|
      NationalQueue::BroadcastStudentQueueUpdate.call(assistance_request: assistance_request)
    end

    updates = smart_task_result.assigned_tasks
    context.updates = updates
  end

end
