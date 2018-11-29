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

    queue_json = QueueSerializer.new(@program, root: false).to_json
    $redis_pool.with do |conn|
      conn.set("program:#{@program.id}:queue", queue_json)
    end

    val = %({"type": "QueueUpdate","queue":#{queue_json}})
    puts val
    # ActionCable.server.broadcast("queue", {
    #   type: 'QueueUpdate',
    #   queue: queue_json
    # })
    ActionCable.server.broadcast("queue", val)
  end

end
