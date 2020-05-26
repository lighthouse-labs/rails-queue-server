class AssistancesController < ApplicationController

  before_action :super_admin_required

  def index
    @assistance_requests = Assistance.all
  end

end
