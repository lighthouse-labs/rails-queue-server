class SmartQueueRouter::UpdateQueues

  include Interactor

  before do
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

      program_settings = assistance_request.compass_instance&.settings.try(:[], 'task_router_settings')
      program_settings ||= {}
      desired_task_assignment = @settings[:desired_task_assignment] || get_setting('desired_task_assignment') || 5
      top_results = Hash[score_result.teachers.sort_by { |_k, teacher| teacher[:routing_score].total }.reverse.first desired_task_assignment]

      top_results.each do |_uid, teacher|
        next if teacher[:object].assigned_ar?(assistance_request)

        task = assistance_request.assign_task(teacher[:object])

        next unless task

        teacher[:routing_score].save!
        assigned_assistance_requests.push(assistance_request)
        assigned_tasks.push({ task: task, shared: false })
      end
    end
    context.assigned_tasks = assigned_tasks
    context.assigned_assistance_requests = assigned_assistance_requests
  end

  private

  def get_setting(setting)
    Float(@settings[setting])
  rescue StandardError
    false
  end

end
