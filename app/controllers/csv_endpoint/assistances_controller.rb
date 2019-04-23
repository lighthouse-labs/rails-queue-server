class CsvEndpoint::AssistancesController < CsvEndpoint::BaseController

  def index
    filtered_field_mapping = get_field_mappings(params[:requested_fields])  

    assistance_requests = get_joined_model
    assistance_requests = assistance_requests.select get_select_fields(filtered_field_mapping)
    assistance_requests = add_where_clauses assistance_requests
    assistance_requests = assistance_requests.order created_at: :desc

    pg = ActiveRecord::Base.connection.instance_variable_get(:@connection)
    pg.send_query(assistance_requests.to_sql)
    pg.set_single_row_mode

    csv_data = CSV.generate do |csv|
      csv << csv_header(filtered_field_mapping)
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
      params[:to] = Date.parse(params[:to]) if params[:to].present? && params[:from].blank?
      params[:to] ||= Date.today
      params[:from] ||= params[:to] - 1.year

      assistance_requests = assistance_requests.between_dates(params[:from], params[:to])
    end

    assistance_requests = assistance_requests.for_program(params[:program_id]) if params[:program_id].present?
    assistance_requests = assistance_requests.for_cohort(params[:cohort_id]) if params[:cohort_id].present?

    assistance_requests
  end

  def get_joined_model
    assistance_requests = AssistanceRequest.joins("LEFT OUTER JOIN cohorts ON assistance_requests.cohort_id = cohorts.id")
    assistance_requests = assistance_requests.joins("LEFT OUTER JOIN assistances ON assistance_requests.assistance_id = assistances.id")
    assistance_requests = assistance_requests.joins("LEFT OUTER JOIN programs ON cohorts.program_id = programs.id")
    assistance_requests = assistance_requests.joins("LEFT OUTER JOIN activities ON assistances.activity_id = activities.id")
    assistance_requests = assistance_requests.joins("LEFT OUTER JOIN users assistors ON assistances.assistor_id = assistors.id")
    assistance_requests = assistance_requests.joins("LEFT OUTER JOIN users assistees ON assistances.assistee_id = assistees.id")
  end

  def field_mapping_arr
    {
      id: {statement: "assistance_requests.id", header: "ID"},
      created_at: {statement: "assistance_requests.created_at", header: "Request Created At"},
      canceled_at: {statement: "assistance_requests.canceled_at", header: "Request Canceled At"},
      request_type: {statement: "assistance_requests.type", header: "Request Type"},
      request_reason: {statement: "assistance_requests.reason", header: "Request Reason"},
      cohort_name: {statement: "cohorts.name", header: "Cohort Name"},
      program_name: {statement: "programs.name", header: "Program Name"},
      cohort_day: {statement: "assistance_requests.day", header: "Cohort Day"},
      mentor_id: {statement: "assistors.id", header: "Mentor ID"},
      mentor_name: {statement: "assistors.first_name || ' ' || assistors.last_name", header: "Mentor Name"},
      student_id: {statement: "assistees.id", header: "Student ID"},
      student_name: {statement: "assistees.first_name || ' ' || assistees.last_name", header: "Student Name"},
      assistance_started_at: {statement: "assistances.start_at", header: "Assistance Started At"},
      assistance_ended_at: {statement: "assistances.end_at", header: "Assistance Ended At"},
      activity_id: {statement: "assistances.activity_id", header: "Activity ID"},
      activity_name: {statement: "activities.name", header: "Activity Name"},
      rating: {statement: "assistances.rating", header: "Rating"},
      notes: {statement: "assistances.notes", header: "Notes"},
      student_notes: {statement: "assistances.student_notes", header: "Student Notes"},
    }    
  end

end
