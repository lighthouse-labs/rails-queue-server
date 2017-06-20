class Admin::AssistancesController < Admin::BaseController

  # def index
  #   @activities = Activity.order(average_rating: :desc)
  #   apply_filters
  # end

  def index
    @assistances = Assistance.all.order(created_at: :desc)

    apply_filters

    # Average time it takes to complete and assistance request
    # There has got to be a better way to do this
    @length_arr = @assistances.completed.collect{|s| s.end_at - s.start_at}
    @assist_length_avg = @length_arr.inject{ |sum, el| sum + el }.to_f / @length_arr.size / 60
  end

  private

  def apply_filters
    filter_by_location
  end

  def filter_by_location
    if params[:location].present?
      @assistances = @assistances.joins(:cohort).where('cohorts.location_id' => params[:location])
    end
  end

  def filter_by_keywords
    if params[:keywords].present?
      @users = @users.by_keywords(params[:keywords])
    end
  end

  def filter_by_rating
    params[:rating] ||= 'All'
    @activities = case params[:rating]
    when '1.x'
      @activities.where(average_rating: 1.0..1.999)
    when '2.x'
      @activities.where(average_rating: 2.0..2.999)
    when '3.x'
      @activities.where(average_rating: 3.0..3.999)
    when '4.x'
      @activities.where(average_rating: 4.0..4.999)
    when '5'
      @activities.where(average_rating: 5)
    when 'Unrated'
      @activities.where(average_rating: nil)
    else
      @activities
    end
  end

  def filter_by_type
    @activities = case params[:type]
    when 'Prep'
      @activities.prep
    when 'Bootcamp'
      @activities.bootcamp
    else
      @activities
    end
  end

  def filter_by_stretch
    params[:stretch]  ||= 'Include'
    @activities = case params[:stretch]
    when 'Exclude'
      @activities.core
    when 'Only'
      @activities.stretch
    else
      @activities
    end
  end


end
