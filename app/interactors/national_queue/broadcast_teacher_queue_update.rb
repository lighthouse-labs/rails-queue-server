class NationalQueue::BroadcastTeacherQueueUpdate

  include Interactor

  before do
    @updates = context.updates
  end

  def call
    @updates.each do |update|
      task = update[:task]
      if update[:shared]
        NationalQueueChannel.broadcast 'teacher-national-queue', type: "queueUpdate", object: QueueTaskSerializer.new(task).as_json
      else
        assistor = task.assistor
        # or if task was not routed
        assistor ||= task.assistance_request&.assistance&.assistor
        NationalQueueChannel.broadcast_to assistor, type: "queueUpdate", object: QueueTaskSerializer.new(task).as_json
        NationalQueueChannel.broadcast 'admin-national-queue', type: "queueUpdate", object: QueueTaskSerializer.new(task).as_json
      end
    end

  end

end
