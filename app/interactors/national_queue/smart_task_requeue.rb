class NationalQueue::SmartTaskRequeue

  include Interactor

  before do
    @user_uid = context.user_uid
  end

  def call
    updates = []
    Octopus.using_group(:program_shards) do
      context.assistor = User.find_by(uid: @user_uid)
      next unless context.assistor

      # make sure on_duty status is synchronized across shards

      context.fail! unless @assistor ? context.assistor.set_duty(@assistor.on_duty) : context.assistor.toggle_duty
      @assistor = context.assistor
    end
    context.fail! unless @assistor
    smart_task_result = if @assistor.on_duty?
                          SmartQueueRouter::AssignQueue.call(
                            assistor: @assistor
                          )
                        else
                          SmartQueueRouter::ReassignQueue.call(
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
