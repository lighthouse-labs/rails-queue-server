class Content::PublishDeploySummary

  include Interactor

  before do
    @log          = context.log
    @deployment   = context.deployment
    @results      = context.results

    if @results
      @updated    = @results.updated
      @created    = @results.created
      @archived   = @results.archived
    end
  end

  def call
    @deployment.status == "completed" ? generate_success_message : generate_failed_message
    notify_slack_channel if ENV['SLACK_WEBHOOK_CURRICULUM_DEPLOYMENTS']
  end

  private

  def generate_success_message
    @log.info "PUBLISHING DEPLOYMENT INFO (c: #{@created.size}, u: #{@updated.size},  r: #{@archived.size})"
    @message = ["New Curriculum Deployment! Woohoo!"]
    @message << "#{@created.size} new activities." unless @created.empty?
    @message << "#{@updated.size} activities updated." unless @updated.empty?
    @message << "#{@archived.size} activities removed (archived)." unless @archived.empty?

    if prev_deployment = @deployment.prev
      compare_link = @deployment.github_compare_link_against(prev_deployment)
      @message << "Details here: <#{compare_link}>"
    end
  end

  def generate_failed_message
    @log.info "PUBLISHING FAILED DEPLOYMENT INFO - id: #{@deployment.id}"
    @message = ["*WARNING: CURRICULUM DEPLOYMENT FAILED*"]
    @message << "exception: #{@deployment.error_message}"
  end

  def notify_slack_channel
    @log.info @message

    NotifySlackChannel.call(
      webhook: ENV['SLACK_WEBHOOK_CURRICULUM_DEPLOYMENTS'],
      message: @message.join("\n")
    )
  end

end
