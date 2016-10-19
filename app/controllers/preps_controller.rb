class PrepsController < ApplicationController

  def show
    redirect_to_first_activity
  end

  def index
    redirect_to_first_activity
  end

  private

  def redirect_to_first_activity
    if params[:id].present? && Prep.find_by(slug: params[:id])
      @prep = Prep.find_by(slug: params[:id])
    else
      @prep = Prep.first
    end
    @activity = @prep.activities.chronological.active.first
    redirect_to prep_activity_path(@prep, @activity)
  end

end