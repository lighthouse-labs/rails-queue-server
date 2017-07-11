class Content::PublishDeploySummary

  include Interactor

  before do
    @log        = context.log
    @updated    = context.updated
    @created    = context.created
    @archived   = context.archived
    @deployment = context.deployment

    @log.info "PUBLISHING DEPLOYMENT INFO (c: #{@created.size}, u: #{@updated.size},  r: #{@archived.size})"
  end

  def call
    message =  ["New Curriculum Deployment! Woohoo!"]
    message << "#{@created.size} new activities." unless @created.empty?
    message << "#{@updated.size} activities updated." unless @updated.empty?
    message << "#{@archived.size} activities removed (archived)." unless @archived.empty?

    if prev_deployment = @deployment.prev
      compare_link = @deployment.github_compare_link_against(prev_deployment)
      message << "Details here: <#{compare_link}>"
    end

    @log.info message

    NotifySlackChannel.call(
      webhook: ENV['SLACK_WEBHOOK_CURRICULUM_DEPLOYMENTS'],
      message: message.join("\n")
    )
  end

end
