class FeedbacksController < ApplicationController

  before_action :super_admin_required

  def index
    @feedbacks = Feedback.all
  end

  def show
    @feedback = Feedback.find_by(id: params[:id])
  end

end
