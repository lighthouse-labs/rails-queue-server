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
    # filter_by_type
    # filter_by_stretch
    # filter_by_notes
    # filter_by_lectures
    # filter_by_rating
    # filter_by_day
  end

  def filter_by_project
    params[:project] ||= 'All'
    params[:project] == 'All' ? @evaluations : @evaluations = @evaluations.where(project_id: params[:project])
  end

  def filter_by_archived
    params[:archived] ||= 'Exclude'
    # byebug
    # @evaluations = case params[:archived]
    #                when 'Exclude'
    #                  @evaluations.active
    #                when 'Only'
    #                  @evaluations.archived
    #                else
    #                  @evaluations
    #                end
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

  def filter_by_stretch
    params[:stretch] ||= 'Include'
    @evaluations = case params[:stretch]
                   when 'Exclude'
                     @evaluations.core
                   when 'Only'
                     @evaluations.stretch
                   else
                     @evaluations
                   end
  end

  def filter_by_notes
    params[:notes] ||= 'Exclude'
    @evaluations = case params[:notes]
                   when 'Only'
                     @evaluations.where(type: 'PinnedNote')
                   when 'Exclude'
                     @evaluations.where.not(type: 'PinnedNote')
                   else
                     @evaluations
    end
  end

  def filter_by_lectures
    params[:lectures] ||= 'Exclude'
    @evaluations = case params[:lectures]
                   when 'Only'
                     @evaluations.where(type: %w[Lecture Breakout])
                   when 'Exclude'
                     @evaluations.where.not(type: %w[Lecture Breakout])
                   else
                     @evaluations
    end
  end

  def filter_by_day
    @evaluations = @evaluations.where("lower(day) LIKE ?", "%#{params[:day].downcase}%") if params[:day].present?
    @evaluations
  end

end
