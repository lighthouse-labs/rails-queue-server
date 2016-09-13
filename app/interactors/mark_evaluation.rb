class MarkEvaluation
  include Interactor

  def call
    @evaluation_form = context.evaluation_form
    @evaluation = context.evaluation
    @evaluation.teacher_notes = @evaluation_form[:teacher_notes]
    if context.decision == "Accept"
      @evaluation.transition_to :accepted
    else
      @evaluation.transition_to :rejected
    end

    context.fail! unless @evaluation.save
  end
end
