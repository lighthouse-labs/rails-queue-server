class SmartQueueRouter::AssignQueue

  include Interactor

  before do
    @assistor = context.assistor
    @settings = context.settings || {}
  end

  def call
    assigned_tasks = []
    @active_requests = AssistanceRequest.pending.oldest_requests_first
    @active_requests.each do |assistance_request|
      score_result = SmartQueueRouter::ScoreForAr.call({
        assistance_request: assistance_request,
        settings:           @settings
      })
      next unless score_result.success?

      desired_task_assignment = @settings[:desired_task_assignment] || 5
      top_results = Hash[score_result.teachers.sort_by { |_k, teacher| teacher[:routing_score] }.reverse.first desired_task_assignment]
      next unless top_results[@assistor.id]
      next if @assistor.assigned_ar?(assistance_request)

      task = assistance_request.assign_task(@assistor)
      next unless task

      assigned_tasks.push({ task: task, shared: false })
    end
    context.assigned_tasks = assigned_tasks
  end

end
