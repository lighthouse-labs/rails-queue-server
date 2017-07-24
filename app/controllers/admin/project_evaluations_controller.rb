class Admin::ProjectEvaluationsController < ApplicationController

  DEFAULT_PER = 5

  def index
    @evaluations = Evaluation.page(params[:page]).per(DEFAULT_PER)
    @project_names = Project.pluck(:name, :id)
    @locations = Location.pluck(:name, :id)
    apply_filters
  end

  private

  def apply_filters
    filter_by_project
    filter_by_start_date
    filter_by_end_date
    filter_by_location
    filter_by_keywords
    exclude_incomplete
    exclude_autocomplete
  end

  def filter_by_project
    params[:project] ||= 'All'
    params[:project] == 'All' ? @evaluations : @evaluations = @evaluations.where(project_id: params[:project])
  end

  def filter_by_start_date
    params[:start_date] ||= Date.current.beginning_of_month
    @evaluations = @evaluations.where("evaluations.updated_at > ?", params[:start_date])
  end

  def filter_by_end_date
    params[:end_date] = if params[:end_date]
                          Date.parse(params[:end_date])
                        else
                          Date.current
                        end
    end_date_end_of_day = params[:end_date].end_of_day.to_s
    @evaluations = @evaluations.where("evaluations.updated_at < ?", end_date_end_of_day)
  end

  def filter_by_location
    params[:location_id] ||= 'All'
    if params[:location_id] == 'All'
      @evaluations
    else
      @evaluations = @evaluations.student_location(Location.find(params[:location_id]))
    end
  end

  def filter_by_keywords
    @evaluations = @evaluations.by_keywords(params[:keywords]) if params[:keywords].present?
  end

  def exclude_incomplete
    params[:incomplete] ||= 'Exclude'
    @evaluations = case params[:incomplete]
                   when 'Exclude'
                     @evaluations.completed
                   when 'Only'
                     @evaluations.incomplete
                   when 'Include'
                     @evaluations
                   end
  end

  def exclude_autocomplete
    params[:auto_accepted] ||= 'Exclude'
    @evaluations = case params[:auto_accepted]
                   when 'Exclude'
                     @evaluations.where.not(state: 'auto_accepted')
                   when 'Include'
                     @evaluations
                   end
  end

end
