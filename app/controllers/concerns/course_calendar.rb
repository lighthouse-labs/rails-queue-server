module CourseCalendar
  extend ActiveSupport::Concern

  included do
    helper_method :today
    helper_method :today?
    helper_method :previous_day?
    helper_method :day
    helper_method :weekend?
    before_filter :allowed_day?
  end

  private

  def weekend?
    !!(day.to_s =~ /(?<=w\d)e$/)
  end

  def friday?
    !!(today.to_s =~ /[w][1-8][d][5]/)
  end

  def week
    day.to_s.match(/^w(\d+)/)[1].to_i
  end

  def day
    return @day if @day
    d = params[:number] || params[:day_number]
    @day = case d
    when 'today'
      today
    when 'yesterday'
      yesterday
    when nil
      activity = if params[:uuid]
        Activity.find_by(uuid: params[:uuid])
      elsif params[:activity_id]
        Activity.find_by(id: params[:activity_id])
      end
      activity.try(:day) || today
    else
      d
    end
    @day = CurriculumDay.new(@day, cohort) if @day.is_a?(String)
    @day
  end

  def today
    @today ||= CurriculumDay.new(Date.current, cohort)
  end

  def today?
    day == today
  end

  def previous_day?
    day.to_s < today.to_s
  end

  def yesterday
    @yesterday ||= CurriculumDay.new(Date.current.yesterday, cohort)
  end

  def allowed_day?
    return true if params[:prep_id]
    unless current_user.can_access_day?(day)
      if today?
        redirect_to(prep_index_path, alert: 'Access not allowed yet.')
      else
        redirect_to(day_path('today'), alert: 'Access not allowed yet.')
      end
    end
  end

end
