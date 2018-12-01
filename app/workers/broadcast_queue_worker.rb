class BroadcastQueueWorker

  include Sidekiq::Worker

  # Don't want it to retry failed websocket updates. Move on!
  # https://github.com/mperham/sidekiq/wiki/Error-Handling
  sidekiq_options retry: false, queue: 'realtime'

  def perform(program_id = nil)
    program = program_id ? Program.find(program_id) : Program.first
    RequestQueue::BroadcastUpdate.call(program: program)
  end

end
