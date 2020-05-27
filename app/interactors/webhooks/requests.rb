class Webhooks::Requests
  
  include Interactor

  before do
    @model         = context.model
    @resource_type = context.resource_type
    @action        = context.action
    @object        = context.object
  end

  def call
    webhooks = Webhook.for_model(@model).for_action(@action).for_resource_type(@resource_type)
    webhooks.each do |webhook|
      uri = URI.parse(webhook.url)
      request = Net::HTTP::Post.new(uri.request_uri)
      request["content-type"] = "application/json"
      request["Authorization"] = webhook.compass_instance.key
      if @object.is_a? Assistance
        body = {
          assistance: AssistanceSerializer.new(@object).as_json,
          assistanceRequest: AssistanceRequestSerializer.new(@object.assistance_request).as_json
        }
      elsif @object.is_a? Feedback
        body = {
          feedback: @object
        }
      end
      request.body = body.to_json
      # 2ADD re request if request failed, and make request non blocking?
      http = Net::HTTP.new(uri.host, uri.port)
      response = http.request(request)
      context.fail! unless response.code.to_i == 200
    end

  end
end
