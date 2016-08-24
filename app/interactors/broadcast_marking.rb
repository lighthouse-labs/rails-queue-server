class BroadcastMarking
  include Interactor

  def call
    evaluation = context.evaluation
    ActionCable.server.broadcast "assistance-#{evaluation.student.cohort.location.name}", {
      type: "StartMarking",
      object: EvaluationSerializer.new(evaluation, root: false).as_json
    }
  end
end
