class Admin::ActivitiesController < Admin::BaseController

  def index
    @activities = Activity.order(average_rating: :desc)
  end

end
