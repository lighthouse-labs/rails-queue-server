class Admin::AssistancesController < Admin::BaseController

  # def index
  #   @activities = Activity.order(average_rating: :desc)
  #   apply_filters
  # end

  def index
    @assistances = Assistance.all.order(created_at: :desc)
  end

  private

  def apply_filters
    filter_by_archived
    filter_by_type
    filter_by_stretch
    filter_by_notes
    filter_by_lectures
    filter_by_rating
    filter_by_day
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

  def filter_by_archived
    params[:archived] ||= 'Exclude'
    @activities = case params[:archived]
    when 'Exclude'
      @activities.active
    when 'Only'
      @activities.archived
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

  def filter_by_notes
    params[:notes]    ||= 'Exclude'
    @activities = case params[:notes]
    when 'Only'
      @activities.where(type: 'PinnedNote')
    when 'Exclude'
      @activities.where.not(type: 'PinnedNote')
    else
      @activities
    end
  end

  def filter_by_lectures
    params[:lectures] ||= 'Exclude'
    @activities = case params[:lectures]
    when 'Only'
      @activities.where(type: ['Lecture', 'Breakout'])
    when 'Exclude'
      @activities.where.not(type: ['Lecture', 'Breakout'])
    else
      @activities
    end
  end

  def filter_by_day
    @activities = @activities.where("lower(day) LIKE ?", "%#{params[:day].downcase}%") if params[:day].present?
    @activities
  end

end
