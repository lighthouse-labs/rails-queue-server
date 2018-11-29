class BroadcastEvaluationToTeachers

  include Interactor

  def call
    evaluation = context.evaluation
    ActionCable.server.broadcast "assistance-#{evaluation.student.cohort.location.name}", type:   "EvaluationRequest",
                                                                                          object: EvaluationSerializer.new(evaluation, root: false).as_json

    RequestQueue::BroadcastUpdate.call(program: Program.first)
  end

end
