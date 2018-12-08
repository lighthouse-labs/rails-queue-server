class RequestQueue::BroadcastUpdate

  include Interactor

  before do
    @program = context.program || Program.first
  end

  def call
    queue_json = QueueSerializer.new(@program, root: false).to_json
    # We do this the ugly way (manually gen the final json payload) in order to avoid unncessary
    # decode/encode of the large queue JSON payload
    json = %({"type": "QueueUpdate","queue":#{queue_json}})
    ActionCable.server.broadcast("queue", json)

    # Write latest queue to Redis cache
    # Used later by adhoc fetches
    $redis_pool.with do |conn|
      conn.set("program:#{@program.id}:queue", queue_json)
    end
  end

end
