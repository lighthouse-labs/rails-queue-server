class PrepsController < ApplicationController

  def show
    redirect_to_first_activity
  end

  def index
    redirect_to_first_activity
  end

  private

  def redirect_to_first_activity
    @prep = params[:id].present? ? Prep.active.find_by!(slug: params[:id]) : Prep.active.first
    if @prep
      @activity = @prep.activities.chronological.active.first
      if @activity
        redirect_to prep_activity_path(@prep, @activity)
        return
      end
    end

    # didn't redirect to prep activity
    redirect_to :welcome, alert: 'No Prep Course Available'
  end

end
