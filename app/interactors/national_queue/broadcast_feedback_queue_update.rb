class NationalQueue::BroadcastFeedbackQueueUpdate

  include Interactor

  before do
    @updates = context.updates
  end

  def call
    puts '++broadcast feedback queue update ++++++++++++++++++++='
    @updates.each do |update|
      task = update[:task]
      if task.assistance_request&.assistance&.feedback
        NationalQueueChannel.broadcast_to task.assistance_request&.requestor, type: "queueUpdate", object: QueueTaskSerializer.new(task).as_json
      end
    end
  end

end
