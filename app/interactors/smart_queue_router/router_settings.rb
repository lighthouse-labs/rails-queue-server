class SmartQueueRouter::RouterSettings

  include Interactor

  before do
    @settings = context.settings || {}
  end

  def call
    program_settings = Program.first&.settings.try(:[], 'task_router_settings')
    program_settings ||= {}
    context.task_penalty = @settings[:task_penalty] || get_setting('task_penalty') || -2
    context.assistance_penalty = @settings[:assistance_penalty] || get_setting('assistance_penalty') || -1
    context.evaluation_penalty = @settings[:evaluation_penalty] || get_setting('evaluation_penalty') || 0
    context.tech_interview_penalty = @settings[:tech_interview_penalty] || get_setting('tech_interview_penalty') || -3
    context.same_location_bonus = @settings[:same_location_bonus] || get_setting('same_location_bonus') || 5
    context.rating_multiplier = @settings[:rating_multiplier] || get_setting('rating_multiplier') || 1.5
    context.desired_task_assignment = @settings[:desired_task_assignment] || get_setting('desired_task_assignment') || 5
    context.max_queue_size = @settings[:max_queue_size] || get_setting('max_queue_size') || 10
  end

  private

  def get_setting(setting)
    Float(@settings[setting])
  rescue StandardError
    false
  end

end
