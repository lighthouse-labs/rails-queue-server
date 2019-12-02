class ProgrammingTestConfigWorker

  class HttpError < StandardError; end

  include Sidekiq::Worker

  sidekiq_options queue: 'default', retry: 0

  def perform(programming_test_id)
    @programming_test = ProgrammingTest.find(programming_test_id)

    return unless programming_test.config.nil?

    url = "/api/v2/exams/#{programming_test.exam_code}"

    resp = api_connector.get(url)

    if resp.status == 200
      programming_test.config = resp.body
      programming_test.save!
    else
      raise HttpError, "Unable to fetch ProgrammingTest config: #{resp.body}"
    end
  end

  private

  def proctor_host_url(pt)
    pt.cohort.program.proctor_url
  end

  def proctor_auth_token(pt)
    pt.cohort.program.proctor_read_token
  end

  def api_connector
    @api_connector ||= Faraday.new(proctor_host_url) do |faraday|
      faraday.request :json
      faraday.authorization :Token, token: proctor_auth_token

      faraday.response :json, content_type: /\bjson$/

      faraday.adapter Faraday.default_adapter
    end
  end

end
