class RequestQueue::BroadcastUpdate

  include Interactor

  before do
    @program = context.program || Program.first
  end

  def call
    # Opportunity to read from a cache in redis.
    # For that we'd need a timestamp but there's no queue record in the db to "touch" (updated_at)
    # I guess we could have a redis val with the updated at instead actually
    # Too lazy to implement that no (lazy optimization is the best type of optimization, right?)
    # - KV
    ActionCable.server.broadcast("queue", {
      type: 'QueueUpdate',
      queue: QueueSerializer.new(@program, root: false)
    })
  end

end
