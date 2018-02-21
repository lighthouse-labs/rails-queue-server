class AssistancesController < ApplicationController

  before_action :teacher_required
  before_action :load_student, except: [:view_code_review_modal]

  def index
    @assistance_requests = @student.completed_assistance_requests.reverse
    @assistance_requests_count = @assistance_requests.count
    @assistance_requests_average_rating = ((@assistance_requests.inject(0) { |total, ar| total + ar.assistance.rating }) / @assistance_requests_count.to_f).round(1)
    @assistance = Assistance.new(assistor: current_user, assistee: @student)
  end

  private

  def teacher_required
    redirect_to(:root, alert: 'Not allowed') unless teacher?
  end

  def load_student
    @student = Student.find(params[:student_id])
  end

end
