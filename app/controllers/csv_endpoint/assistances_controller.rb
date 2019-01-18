class CsvEndpoint::AssistancesController < CsvEndpoint::BaseController

  def index
    assistance_requests = get_joined_model
    assistance_requests = assistance_requests.select get_select_fields
    assistance_requests = add_where_clauses assistance_requests
    assistance_requests = assistance_requests.order created_at: :desc

    pg = ActiveRecord::Base.connection.instance_variable_get(:@connection)
    pg.send_query(assistance_requests.to_sql)
    pg.set_single_row_mode

    csv_data = CSV.generate do |csv|
      csv << csv_header
      pg.get_result.stream_each_row do |row|
        csv << row
      end
    end

    send_data csv_data, filename: "assistance_requests.csv"
  end

  private

  def add_where_clauses(assistance_requests)
    if params[:location].present?
      location = Location.find_by(name: params[:location])
      assistance_requests = assistance_requests.for_location(location)
    end

    if params[:from].present? || params[:to].present?
      params[:to] = Date.parse(params[:to]) if params[:to].present? && !params[:from].present?
      params[:to] ||= Date.today
      params[:from] ||= params[:to] - 1.year

      assistance_requests = assistance_requests.between_dates(params[:from], params[:to])
    end

    assistance_requests = assistance_requests.for_program(params[:program_id]) if params[:program_id].present?
    assistance_requests = assistance_requests.for_cohort(params[:cohort_id]) if params[:cohort_id].present?

    assistance_requests
  end

  def get_joined_model
    AssistanceRequest.joins("LEFT OUTER JOIN cohorts ON assistance_requests.cohort_id = cohorts.id")
    assistance_requests = assistance_requests.joins("LEFT OUTER JOIN assistances ON assistance_requests.assistance_id = assistances.id")
    assistance_requests = assistance_requests.joins("LEFT OUTER JOIN programs ON cohorts.program_id = programs.id")
    assistance_requests = assistance_requests.joins("LEFT OUTER JOIN activities ON assistances.activity_id = activities.id")
    assistance_requests = assistance_requests.joins("LEFT OUTER JOIN users assistors ON assistances.assistor_id = assistors.id")
    assistance_requests = assistance_requests.joins("LEFT OUTER JOIN users assistees ON assistances.assistee_id = assistees.id")    
  end

  def csv_header
    [
      "Request Created_at",
      "Canceled?",
      "Request Type",
      "Reason",
      "Cohort",
      "Program",
      "Day",
      "Mentor ID",
      "Mentor Name",
      "Student ID",
      "Student Name",
      "Assistance Started_At",
      "Assistance Ended_At",
      "Activity ID",
      "Activity Name",
      "Rating",
      "Notes",
      "Student Notes"
    ]
  end

  def get_select_fields
    [
      "assistance_requests.created_at",
      "assistance_requests.canceled_at",
      "assistance_requests.type",
      "assistance_requests.reason",    
      "cohorts.name",
      "programs.name",      
      "assistance_requests.day",
      "assistors.id",
      "assistors.first_name || ' ' || assistors.last_name",
      "assistees.id",
      "assistees.first_name || ' ' || assistees.last_name",
      "assistances.start_at",
      "assistances.end_at",
      "assistances.activity_id",
      "activities.name",
      "assistances.rating",
      "assistances.notes",
      "assistances.student_notes"
    ]
  end
end
