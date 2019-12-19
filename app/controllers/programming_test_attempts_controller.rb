require 'faraday_middleware'

class ProgrammingTestAttemptsController < ApplicationController

  before_action :set_programming_test

  def show
    attempt = @programming_test.attempts.where(
      student: current_user,
      cohort:  cohort
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
      cohort:  cohort
    )

    if attempt.persisted?
      if attempt.ready?
        return render json: { attempt: attempt }
      elsif attempt.errored?
        attempt.reset
      end
    end

    unless attempt.save
      return render json: { message: 'Unable to save attempt', errors: attempt.errors }, status: :internal_server_error
    end

    begin
      response = api_connector.put proctor_url_for_attempt do |req|
        req.body = attempt_request_body
      end

      if response.success?
        attempt.token = response.body["examToken"]
        render json: { attempt: attempt }
      else
        attempt.errored = response.body
        render json: { error: response.body }, status: :internal_server_error
      end
    rescue StandardError => error
      attempt.errored = error
      render json: { error: 'Error connecting to proctor server, please let your instructor know' }, status: :internal_server_error
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
    cohort.program.proctor_url
  end

  def proctor_auth_token
    cohort.program.proctor_write_token
  end

  def api_connector
    @api_connector ||= Faraday.new(proctor_host_url) do |faraday|
      faraday.request :json
      faraday.authorization :Token, token: proctor_auth_token

      faraday.response :json, content_type: /\bjson$/

      faraday.adapter Faraday.default_adapter
    end
  end

  def student_id
    current_user.current_enrollment_id
  end

  def attempt_request_body
    {
      student_id: student_id
    }
  end

  def proctor_url_for_attempt
    "/api/v2/exams/#{@programming_test.exam_code}/attempt"
  end

end
