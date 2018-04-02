class Teacher::CohortSwitcherController < Teacher::BaseController

  def index
    @filtered_cohorts = Cohort.most_recent_first.all.page(params[:page])

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
      @filtered_cohorts = @filtered_cohorts.starts_between(date - 8.weeks, date)
    end
  end

  def filter_started_after_date
    if params[:started_after_date].present?
      date = Date.parse(params[:started_after_date])
      @filtered_cohorts = @filtered_cohorts.started_after(date)
    end
  end

  def filter_started_before_date
    if params[:started_before_date].present?
      date = Date.parse(params[:started_before_date])
      @filtered_cohorts = @filtered_cohorts.started_before(date)
    end
  end

  def filter_by_location
    if params[:location_id].blank?
      @filtered_cohorts
    else
      location = Location.find params[:location_id]
      @filtered_cohorts = if location.supported_by_location
                   @filtered_cohorts.where(location_id: location.supported_by_location.id)
                 else
                   @filtered_cohorts.where(location_id: location.id)
                 end
    end
  end

  def filter_by_status
    params[:status] ||= 'Active/Finished'
    @filtered_cohorts = case params[:status]
               when 'Upcoming'
                 @filtered_cohorts.upcoming
               when 'Active'
                 @filtered_cohorts.is_active
               when 'Active/Finished'
                 @filtered_cohorts.started_before(Date.current)
               when 'Finished'
                 @filtered_cohorts.is_finished
               else
                 @filtered_cohorts
               end
  end

  def filter_by_keywords
    @filtered_cohorts = @filtered_cohorts.by_keywords(params[:keywords]) if params[:keywords].present?
  end

end
