class ProgrammingTestConfigWorker

  class HttpError < StandardError; end

  include Sidekiq::Worker

  sidekiq_options queue: 'default'

  def perform(programming_test_id)
    programming_test = ProgrammingTest.find(programming_test_id)
    # TODO: Fix this when we have multiple programs
    program = Program.first

    return unless programming_test.config.nil?

    url = "/api/v2/exams/#{programming_test.exam_code}"

    resp = api_connector(program).get(url)

    if resp.status == 200
      programming_test.config = resp.body
      programming_test.save!
    else
      raise HttpError, "Unable to fetch ProgrammingTest config: #{resp.body}"
    end
  end

  private

  def api_connector(program)
    @api_connector ||= Faraday.new(program.proctor_url) do |faraday|
      faraday.request :json
      faraday.authorization :Token, token: program.proctor_read_token

      faraday.response :json, content_type: /\bjson$/

      faraday.adapter Faraday.default_adapter
    end
  end

end
