require 'faraday_middleware'

class ProgrammingTestAttemptsController < ApplicationController

  before_action :set_programming_test

  def show
    attempt = @programming_test.attempts.where(
      student: current_user,
      cohort:  current_user.cohort
    ).first

    if attempt
      render json: { attempt: attempt }
    else
      render json: { error: 'Not Found' }, status: :not_found
    end
  end

  def create
    attempt = @programming_test.attempts.find_or_initialize_by(
      student: current_user,
      cohort:  current_user.cohort
    )

    if attempt.persisted? && attempt.current_state == 'ready'
      render json: { attempt: attempt }
      return
    end

    unless attempt.save
      render json: { message: 'Unable to save attempt', errors: attempt.errors }, status: 500
      return
    end

    response = api_connector.put proctor_url_for_attempt do |req|
      req.body = attempt_request_body
    end

    if response.success?
      attempt.transition_to(:ready, token: response.body["examToken"])
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
    ENV.fetch('PROCTOLOGIST_URL')
  end

  def proctor_auth_token
    ENV.fetch('PROCTOLOGIST_TOKEN')
  end

  def api_connector
    @api_connector ||= Faraday.new proctor_host_url do |faraday|
      faraday.request :json
      faraday.authorization :Token, token: proctor_auth_token

      faraday.response :json, content_type: /\bjson$/

      faraday.adapter Faraday.default_adapter
    end
  end

  def student_id
    current_user.github_username
  end

  def enrollment_id
    "#{student_id}-#{current_user.cohort.id}"
  end

  def attempt_request_body
    {
      student_id:    student_id,
      enrollment_id: enrollment_id
    }
  end

  def proctor_url_for_attempt
    "/api/v2/exams/#{@programming_test.exam_code}/attempt"
  end

end
