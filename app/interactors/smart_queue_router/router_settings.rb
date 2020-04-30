class SmartQueueRouter::RouterSettings

  include Interactor

  before do
    @settings = context.settings || {}
  end

  def call
    program_settings = Program.first&.settings.try(:[], 'task_router_settings')
    program_settings ||= {}
    context.task_penalty = @settings[:task_penalty] || program_settings['task_penalty'] || -5
    context.assistance_penalty = @settings[:assistance_penalty] || program_settings['assistance_penalty'] || -4
    context.evaluation_penalty = @settings[:evaluation_penalty] || program_settings['evaluation_penalty'] || 0
    context.tech_interview_penalty = @settings[:tech_interview_penalty] || program_settings['tech_interview_penalty'] || -10
    context.same_location_bonus = @settings[:same_location_bonus] || program_settings['same_location_bonus'] || 5
    context.rating_multiplier = @settings[:rating_multiplier] || program_settings['rating_multiplier'] || 1.5
    context.desired_task_assignment = @settings[:desired_task_assignment] || program_settings['desired_task_assignment'] || 5
    context.max_queue_size = @settings[:max_queue_size] || program_settings['max_queue_size'] || 5
  end

end
