class PrepAssistanceRequestsController < ApplicationController

  def create
    @user = current_user
    @activity = Activity.find(params[:activity_id]) if params[:activity_id]
    @prep_assistance_request = PrepAssistanceRequest.new(user: @user, activity: @activity)
    @prep_assistance_request.save!
    redirect_to "http://web-prep-help.lighthouselabs.ca/"
  end

end
