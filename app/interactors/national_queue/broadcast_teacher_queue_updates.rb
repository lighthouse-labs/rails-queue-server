class NationalQueue::BroadcastTaskUpdates

  include Interactor

  before do
    @updates = context.updates
  end

  def call
    @updates.each do |update|
      task = update[:task]
      if update[:shared]
        NationalQueueChannel.broadcast 'teacher-national-queue' , type: "update", object: QueueTaskSerializer.new(task).as_jsonQueueTaskSerializer
      else
        NationalQueueChannel.broadcast task.asignee , type: "update", object: QueueTaskSerializer.new(task).as_jsonQueueTaskSerializer
      end
    end
  end

end
