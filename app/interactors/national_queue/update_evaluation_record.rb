class NationalQueue::UpdateEvaluationRecord

  include Interactor

  before do
    @evaluation = Evaluation.find_by id: context.options[:evaluation_id]
    @options = context.options
    @assistor = context.assistor
  end

  def call
    context.updates ||= []

    case @options[:type]
    when 'cancel_evaluating'
      context.assistor = @evaluation.teacher
      if @evaluation&.can_requeue?
        @evaluation.teacher = nil
        context.updates.push({ task: @evaluation, shared: true }) if success = @evaluation.transition_to(:pending)
      end
    when 'start_evaluating'
      if @evaluation&.grabbable_by?(@assistor)
        @evaluation.teacher = @assistor
        context.updates.push({ task: @evaluation, shared: true }) if success = @evaluation.transition_to(:in_progress)
      end
    end

    context.fail! unless success
  end

end
