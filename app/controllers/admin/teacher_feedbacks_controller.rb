class Admin::TeacherFeedbacksController < Admin::BaseController

  FILTER_BY_OPTIONS = [:teacher_id, :teacher_location_id, :start_date, :end_date].freeze

  def index
    params[:teacher_location_id] ||= current_user.location.id.to_s
    params[:start_date] ||= Date.current.beginning_of_month.to_s
    params[:end_date] ||= Date.current.end_of_month.to_s

    @feedbacks = Feedback.teacher_feedbacks.filter_by(filter_by_params)
    @completed_feedbacks = Feedback.teacher_feedbacks.completed.filter_by(filter_by_params).group_by(&:teacher)
  end

  private

  def filter_by_params
    params.slice(*FILTER_BY_OPTIONS).select { |_k, v| v.present? }
  end

end
