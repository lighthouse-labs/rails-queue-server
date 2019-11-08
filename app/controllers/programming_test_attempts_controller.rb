require 'faraday_middleware'

class ProgrammingTestAttemptsController < ApplicationController

  before_action :set_programming_test
  attr_reader :programming_test

  def create
    attempt = programming_test.attempts.build(
      student: current_user,
      cohort:  current_user.cohort
    )

    unless attempt.save
      render json: { message: 'Unable to save attempt', errors: attempt.errors }, status: 500
      return
    end

    response = api_connection.post attempt_url do |req|
      req.body = attempt_request_body
    end

    if response.success?
      attempt.transition_to(:ready, token: response.body["examToken"])
      attempt.token = response.body["examToken"]
      attempt.save
      render json: { attempt: attempt }
    else
      attempt.transition_to(:errored, response.body)
      render json: { error: response.body }, status: :internal_server_error
    end

  end

  private

  def set_programming_test
    @programming_test = ProgrammingTest.find programming_test_id
  end

  def programming_test_id
    params[:programming_test_id]
  end

  def api_connection
    # TODO: Move the URL to an env var
    @api_connection ||= Faraday.new 'http://localhost:3000' do |faraday|
      faraday.request :json
      # TODO: Add in auth for this request
      # faraday.authorization :Token, token: '<token>'

      faraday.response :json, content_type: /\bjson$/

      faraday.adapter Faraday.default_adapter
    end
  end

  def student_id
    current_user.github_username
  end

  def attempt_request_body
    {
      student_id: student_id
    }
  end

  def attempt_url
    "/api/v2/exams/#{programming_test.exam_code}/attempt"
  end

end
