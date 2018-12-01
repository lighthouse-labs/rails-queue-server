class BroadcastEvaluationToTeachers

  include Interactor

  def call
    # evaluation = context.evaluation
    RequestQueue::BroadcastUpdateAsync.call(program: Program.first)
  end

end
