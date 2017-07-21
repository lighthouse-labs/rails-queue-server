class Admin::ProjectEvaluationsController < ApplicationController

  DEFAULT_PER = 5

  def index
    @evaluations = Evaluation.page(params[:page]).per(DEFAULT_PER)
    @project_names = Project.pluck(:name, :id)
    apply_filters
  end

  private

  def apply_filters
    filter_by_project
    filter_by_start_date
    filter_by_end_date
    # filter_by_type
  end

  def filter_by_project
    params[:project] ||= 'All'
    params[:project] == 'All' ? @evaluations : @evaluations = @evaluations.where(project_id: params[:project])
  end

  def filter_by_start_date
    params[:start_date] ||= Date.current.beginning_of_month
    @evaluations = @evaluations.where("updated_at > ?", params[:start_date])
  end

  def filter_by_end_date
    params[:end_date] = if params[:end_date].empty?
                          Date.current
                        else
                          Date.parse(params[:end_date])
                        end
    end_date_end_of_day = params[:end_date].end_of_day.to_s
    @evaluations = @evaluations.where("updated_at < ?", end_date_end_of_day)
  end

  def filter_by_type
    @evaluations = case params[:type]
                   when 'Prep'
                     @evaluations.prep
                   when 'Bootcamp'
                     @evaluations.bootcamp
                   else
                     @evaluations
                   end
                   end

end
