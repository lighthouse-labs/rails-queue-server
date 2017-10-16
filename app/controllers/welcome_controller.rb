class WelcomeController < ApplicationController

  skip_before_action :authenticate_user
  skip_before_action :registration_check

  def show; end

end
