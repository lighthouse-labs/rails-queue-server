# Only for v2 - Assumes the eval has a project that has the new v2 style rubric - KV
class Evaluations::UpdateResult

  include Interactor

  before do
    @evaluation    = context.evaluation
    @teacher_notes = context.evaluation_form[:teacher_notes]
    @result        = context.evaluation_form['result']
  end

  def call
    @evaluation.result = @result
    @evaluation.teacher_notes = @teacher_notes

    if @evaluation.save
      # :)
    else
      context.fail!(error: @evaluation.errrors.full_messages.first)
    end
  end

end
