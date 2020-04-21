class SmartQueueRouter::RouterSettings

  include Interactor

  before do
    @settings = context.settings || {}
  end

  def call
    context.task_penalty = @settings[:task_penalty] || -2
    context.assistance_penalty = @settings[:assistance_penalty] || -1
    context.evaluation_penalty = @settings[:evaluation_penalty] || 0
    context.tech_interview_penalty = @settings[:tech_interview_penalty] || -3
    context.rating_multiplier = @settings[:rating_multiplier] || 2
    context.desired_task_assignment = @settings[:desired_task_assignment] || 5
    context.max_queue_size = @settings[:max_queue_size] || 10
  end

end
