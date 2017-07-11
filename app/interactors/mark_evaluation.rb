class MarkEvaluation

  include Interactor

  def call
    @evaluation_form = context.evaluation_form
    @evaluation = context.evaluation
    @evaluation.teacher_notes = @evaluation_form[:teacher_notes]
    @evaluation.final_score = @evaluation_form[:final_score]

    if context.decision == "Accept"
      @evaluation.transition_to :accepted
      UserMailer.evaluation_accepted(@evaluation).deliver
    else
      @evaluation.transition_to :rejected
      UserMailer.evaluation_rejected(@evaluation).deliver
    end

    context.fail! unless @evaluation.save
  end

end
