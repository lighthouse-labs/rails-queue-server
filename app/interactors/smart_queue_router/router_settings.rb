class SmartQueueRouter::RouterSettings

  include Interactor

  before do
    @settings = context.settings || {}
    @assistance_request = context.assistance_request
  end

  def call
    puts 'router settings ++++++++++++++++++++++++++++++'

    program_settings = @assistance_request.compass_instance&.settings.try(:[], 'task_router_settings')
    program_settings ||= {}
    context.max_queue_weight = @settings[:max_queue_weight] || get_setting('max_queue_weight') || 100
    context.max_queue_size = @settings[:max_queue_size] || get_setting('max_queue_size') || 10
    context.active_task_weight = @settings[:active_task_weight] || get_setting('active_task_weight') || 2
    context.active_assistance_weight = @settings[:active_assistance_weight] || get_setting('active_assistance_weight') || 1
    context.active_evaluation_weight = @settings[:active_evaluation_weight] || get_setting('active_evaluation_weight') || 0
    context.active_tech_interview_weight = @settings[:active_tech_interview_weight] || get_setting('active_tech_interview_weight') || 3
    context.same_location_weight = @settings[:same_location_weight] || get_setting('same_location_weight') || 5
    context.avg_rating_weight = @settings[:avg_rating_weight] || get_setting('avg_rating_weight') || 1.5
    context.successfull_assistance_weight = @settings[:successfull_assistance_weight] || get_setting('successfull_assistance_weight') || 1.5
    context.negative_assistance_weight = @settings[:negative_assistance_weight] || get_setting('negative_assistance_weight') || 1.5
    context.desired_task_assignment = @settings[:desired_task_assignment] || get_setting('desired_task_assignment') || 5
  end

  private

  def get_setting(setting)
    Float(@settings[setting])
  rescue StandardError
    false
  end

end
