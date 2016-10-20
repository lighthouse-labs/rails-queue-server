class PrepsController < ApplicationController

  def show
    redirect_to_first_activity
  end

  def index
    redirect_to_first_activity
  end

  private

  def redirect_to_first_activity
    @prep = params[:id].present? ? Prep.find_by!(slug: params[:id]) : Prep.first
    @activity = @prep.activities.chronological.active.first
    redirect_to prep_activity_path(@prep, @activity)
  end

end