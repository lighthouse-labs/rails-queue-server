class RequestQueue::FetchQueueJson

  include Interactor

  before do
    @rebuild_cache = context.rebuild_cache || false
    @program = context.program || Program.first
  end

  def call
    context.json = full_queue_json(@rebuild_cache)
  end

  private

  def full_queue_json(rebuild_cache = false)
    queue_data_json = queue_json(rebuild_cache)
    # A bit ugly in how we are compiling the _final_ json string
    # However, saves us an unncessary parse/stringify step since it's stored as a string in redis
    %({"queue":#{queue_data_json}})
  end

  def queue_json(rebuild_cache = false)
    $redis_pool.with do |conn|
      if rebuild_cache
        json = QueueSerializer.new(@program, root: false).to_json
        conn.set("program:#{@program.id}:queue", json)
      else
        json = conn.get("program:#{@program.id}:queue")
        unless json
          json = QueueSerializer.new(@program, root: false).to_json
          conn.set("program:#{@program.id}:queue", json)
        end
      end
      json
    end
  end

end
