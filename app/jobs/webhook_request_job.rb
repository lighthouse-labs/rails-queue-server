
class WebhookRequestJob < ActiveJob::Base
  queue_as :default
 
  def perform(url, key, body, repeat=true)
    uri = URI.parse(url)
    request = Net::HTTP::Post.new(uri.request_uri)
    request["content-type"] = "application/json"
    request["Authorization"] = key
    request.body = body
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end
    response = http.request(request)
    # on fail repeat once
    WebhookRequestJob.perform_later(url, key, body, false) unless response.code.to_i == 200
  end

end
