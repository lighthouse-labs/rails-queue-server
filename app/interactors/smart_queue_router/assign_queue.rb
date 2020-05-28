class SmartQueueRouter::AssignQueue

  include Interactor

  before do
    @assistor = context.assistor
    @settings = context.settings || {}
  end

  def call
    assigned_tasks = []
    assigned_assistance_requests = []
    @active_requests = AssistanceRequest.with_routing.pending.oldest_requests_first
    @active_requests.each do |assistance_request|
      score_result = SmartQueueRouter::ScoreForAr.call({
        assistance_request: assistance_request,
        settings:           @settings
      })
      next unless score_result.success?

      desired_task_assignment = @settings[:desired_task_assignment] || 5
      top_results = Hash[score_result.teachers.sort_by { |_k, teacher| teacher[:routing_score].total }.reverse.first desired_task_assignment]
      next unless top_results[@assistor.uid]
      next if @assistor.assigned_ar?(assistance_request)

      task = assistance_request.assign_task(@assistor)
      next unless task
      top_results[@assistor.uid][:routing_score].save!
      assigned_assistance_requests.push(assistance_request)
      assigned_tasks.push({ task: task, shared: false })
    end
    context.assigned_tasks = assigned_tasks
    context.assigned_assistance_requests = assigned_assistance_requests
  end

end
