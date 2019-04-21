class QueueStats

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def run
    {
      request_counts: {
        by_curriculum_day: request_counts_by_curriculum_day,
        by_month: request_counts_by_month,
        by_week: request_counts_by_week,
        by_quarter: request_counts_by_quarter,
      },

      closed_request_waittimes: {
        by_week: closed_request_waittimes_by_week,
        by_quarter: closed_request_waittimes_by_quarter
      }
    }
  end

  private

  def request_counts_by_month
    if time_range_within(3.months..20.years)
      @request_counts_by_month ||= actuals_by_location
        .group_by_month('assistance_requests.start_at', format: "%b %Y")
        .count
    end
  end

  def request_counts_by_week
    if time_range_within(0..3.months)
      @request_counts_by_week ||= actuals_by_location
        .group_by_week('assistance_requests.start_at')
        .count
    end
  end

  def request_counts_by_quarter
    if time_range_within(3.months..20.years)
      @request_counts_by_quarter ||= actuals_by_location
        .group_by_quarter(
          'assistance_requests.start_at',
          format: ->(date) { date.to_formatted_s(:quarter) })
        .count
    end
  end

  def closed_request_waittimes_by_week
    if time_range_within(0..3.months)
      @closed_request_waittimes_by_week ||= assistance_requests
        .closed
        .wait_times_between(0.5, 3600)
        .group('locations.name')
        .reorder('locations.name ASC')
        .group_by_week('assistance_requests.start_at')
        .average('(EXTRACT(EPOCH FROM (assistances.start_at - assistance_requests.start_at)) / 60.0)::float')
    end
  end

  def closed_request_waittimes_by_quarter
    if time_range_within(3.months..20.years)
      @closed_request_waittimes_by_quarter ||= assistance_requests
        .closed
        .wait_times_between(0.5, 3600)
        .group('locations.name')
        .reorder('locations.name ASC')
        .group_by_quarter(
          'assistance_requests.start_at',
          format: ->(date) { date.to_formatted_s(:quarter) })
        .average('(EXTRACT(EPOCH FROM (assistances.start_at - assistance_requests.start_at)) / 60.0)::float')
    end
  end

  def request_counts_by_curriculum_day
    @request_counts_by_curriculum_day ||= assistance_requests
      .group(:day)
      .count
  end

  ###

  def assistance_requests
    return @assistance_requests if @assistance_requests

    requests = AssistanceRequest.all

    if params[:from_date].present?
      requests = requests.where('assistance_requests.start_at >= ?', from_time)
    end

    if params[:to_date].present?
      requests = requests.where('assistance_requests.start_at <= ?', to_time)
    end

    if params[:day].present?
      requests = requests.where(day: params[:day].split(/\s*,\s*/))
    end

    if params[:location_ids].present?
      requests = requests.for_location(params[:location_ids])
    end

    @assistance_requests = requests
      .joins(:assistor_location)
      .references(:assistor_location)
  end

  def actual_requests
    @actual_requests ||= assistance_requests.genuine
  end

  def actuals_by_location
    @actuals_by_location ||= actual_requests
      .group('locations.name')
      .reorder('locations.name ASC')
  end

  ###

  def from_time
    @from_time ||= (params[:from_date].present? ? Time.zone.parse(params[:from_date]) : 10.years.ago)
      .beginning_of_day
  end

  def to_time
    @to_time ||= (params[:to_date].present? ? Time.zone.parse(params[:to_date]) : 1.year.from_now)
      .end_of_day
  end

  def time_range_within(range)
    (to_time - from_time).in? range
  end
end
