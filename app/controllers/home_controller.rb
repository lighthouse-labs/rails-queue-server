class HomeController < ApplicationController

  skip_before_action :authenticate_user

  def show
    if current_user
      if current_user.can_access_day?('w1d1')
        redirect_to day_path('today')
      else
        redirect_to prep_index_path
      end
    else
      redirect_to welcome_path
    end
  end

end
