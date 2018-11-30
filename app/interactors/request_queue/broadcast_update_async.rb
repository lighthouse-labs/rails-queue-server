# Calls RequestQueue::BroadcastUpdate async using bg worker (sidekiq)
# -> workers/broadcast_queue_worker.rb
class RequestQueue::BroadcastUpdateAsync

  include Interactor

  before do
    @program = context.program || Program.first
  end

  def call
    BroadcastQueueWorker.perform_async(@program.id)
  end

end
