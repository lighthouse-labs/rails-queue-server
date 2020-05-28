class NationalQueue::BroadcastFeedbackQueueUpdate

  include Interactor

  before do
    @updates = context.updates
  end

  def call
    @updates.each do |update|
      task = update[:task]
      NationalQueueChannel.broadcast_to task.assistance_request&.requestor, type: "queueUpdate", object: QueueTaskSerializer.new(task).as_json if task.assistance_request&.assistance&.feedback
    end
  end

end
