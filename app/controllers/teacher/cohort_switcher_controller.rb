class Teacher::CohortSwitcherController < Teacher::BaseController

  def index
    @cohorts = Cohort.most_recent_first.all.page(params[:page])

    apply_filters
  end

  def apply_filters
    filter_by_active_at_date
    filter_started_after_date
    filter_started_before_date
    filter_by_location
    filter_by_status
    filter_by_keywords
  end

  def filter_by_active_at_date
    if params[:active_at].present?
      date = Date.parse(params[:active_at])
      @cohorts = @cohorts.starts_between(date - 8.weeks, date)
    end
  end

  def filter_started_after_date
    if params[:started_after_date].present?
      date = Date.parse(params[:started_after_date])
      @cohorts = @cohorts.started_after(date)
    end
  end

  def filter_started_before_date
    if params[:started_before_date].present?
      date = Date.parse(params[:started_before_date])
      @cohorts = @cohorts.started_before(date)
    end
  end

  def filter_by_location
    if params[:location_id].blank?
      @cohorts
    else
      location = Location.find params[:location_id]
      @cohorts = if location.supported_by_location
                   @cohorts.where(location_id: location.supported_by_location.id)
                 else
                   @cohorts.where(location_id: location.id)
                 end
    end
  end

  def filter_by_status
    params[:status] ||= 'All'
    @cohorts = case params[:status]
               when 'Upcoming'
                 @cohorts.upcoming
               when 'Active'
                 @cohorts.is_active
               when 'Finished'
                 @cohorts.is_finished
               else
                 @cohorts
               end
  end

  def filter_by_keywords
    @cohorts = @cohorts.by_keywords(params[:keywords]) if params[:keywords].present?
  end

end
