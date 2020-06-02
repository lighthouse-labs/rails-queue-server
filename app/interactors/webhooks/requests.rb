class Webhooks::Requests

  include Interactor

  before do
    @model            = context.model
    @resource_type    = context.resource_type
    @action           = context.action
    @object           = context.object
    @compass_instance = context.compass_instance
  end

  def call
    webhooks = @compass_instance.webhooks.for_model(@model).for_action(@action).for_resource_type(@resource_type)
    webhooks.each do |webhook|
      if @object.is_a? Assistance
        body = {
          assistance:        AssistanceSerializer.new(@object).as_json,
          assistanceRequest: AssistanceRequestSerializer.new(@object.assistance_request).as_json
        }
      elsif @object.is_a? Feedback
        body = {
          feedback: @object
        }
      end
      WebhookRequestJob.perform_later(webhook.url, webhook.compass_instance.key, body.to_json)
    end
  end

end
