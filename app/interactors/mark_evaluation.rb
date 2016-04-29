class MarkEvaluation
  include Interactor

  def call
    @evaluation_form = context.evaluation_form
    @evaluation = context.evaluation
    if @evaluation_form[:commit] == "Accept"
      @evaluation.accepted == true
    else
      @evaluation.accepted == false
    end

    if @evaluation.save
      result = CreateOutcomeResultsFromEvaluation.call(outcomes: @evaluation_form.outcomes)
      context.fail!(error: result.message) unless result.success
    else
      context.fail!
    end
  end
end
