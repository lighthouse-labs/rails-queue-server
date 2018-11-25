class BroadcastMarking

  include Interactor

  def call
    evaluation = context.evaluation
    evaluator = context.evaluator
    redirect_to = context.edit_evaluation_url

    BroadcastQueueUpdate.call(program: Program.first)
    UserChannel.broadcast_to(evaluator, type: 'RedirectCommand', location: redirect_to) if evaluator
  end

end
