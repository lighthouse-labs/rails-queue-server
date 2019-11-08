require 'faraday_middleware'

class ProgrammingTestAttemptsController < ApplicationController

  before_action :set_programming_test
  attr_reader :programming_test

  def show
    attempt = programming_test.attempts.where(
      student: current_user,
      cohort:  current_user.cohort
    ).limit(1).first

    if attempt
      render json: { attempt: attempt }
    else
      render json: { error: 'Not Found' }, status: :not_found
    end
  end

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

  def proctor_host_url
    ENV.fetch('PROCTOLOGIST_URL') { 'http://localhost:3000' }
  end

  def proctor_auth_token
    ENV.fetch('PROCTOR_HOST_TOKEN') { 'token' }
  end

  def api_connection
    @api_connection ||= Faraday.new proctor_host_url do |faraday|
      faraday.request :json
      faraday.authorization :Token, token: proctor_auth_token

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
