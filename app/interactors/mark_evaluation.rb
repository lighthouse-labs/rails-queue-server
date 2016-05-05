class MarkEvaluation
  include Interactor

  def call
    @evaluation_form = context.evaluation_form
    @evaluation = context.evaluation

    # => Needs to be state-machined
    # => @evaluation.score = 5
    # => @evaluation.reject
    if @evaluation_form[:commit] == "Accept"
      @evaluation.transition_to :accepted
    else
      @evaluation.transition_to :rejected
    end

    context.fail! unless @evaluation.save
  end
end
