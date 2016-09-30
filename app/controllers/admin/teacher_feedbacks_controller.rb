class Admin::TeacherFeedbacksController < Admin::BaseController

  FILTER_BY_OPTIONS = [:teacher_id, :teacher_location_id, :start_date, :end_date].freeze

  def index
    if params[:teacher_location_id].nil?
      params[:teacher_location_id] = current_user.location.id.to_s
    end

    if params[:start_date].nil?
      params[:start_date] = Date.today.beginning_of_month.to_s
    end

    if params[:end_date].nil?
      params[:end_date] = Date.today.end_of_month.to_s
    end

    @feedbacks = Feedback.teacher_feedbacks.filter_by(filter_by_params)
    @completed_feedbacks = Feedback.teacher_feedbacks.completed.filter_by(filter_by_params).group_by(&:teacher)
    @completed_feedbacks_default = Feedback.teacher_feedbacks.completed.filter_by({"teacher_location" => "1", "start_date" => "2016-09-01", "end_date" => "2016-09-30"}).group_by(&:teacher)
  end

  private

  def filter_by_params
    params.slice(*FILTER_BY_OPTIONS).select { |k,v| v.present? }
  end

end