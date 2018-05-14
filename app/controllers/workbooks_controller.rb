class WorkbooksController < ApplicationController

  before_action :require_workbook

  def show
    redirect_to_first_activity
  end

  def index
    redirect_to_first_activity
  end

  private

  def require_workbook
    @workbook = Workbook.active.find_by(slug: params[:id])
  end

  def redirect_to_first_activity
    @work_module = @workbook.work_modules.active.first
    @activity    = @work_module.work_module_items.active.first.try(:activity)
    redirect_to workbook_activity_path(@workbook, @activity)
  end

end
