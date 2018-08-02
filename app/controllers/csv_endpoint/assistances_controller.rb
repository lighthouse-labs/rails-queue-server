class CsvEndpoint::AssistancesController < CsvEndpoint::BaseController

  def index
    assistance_requests = AssistanceRequest

    if params[:location].present?
      location = Location.find_by(name: params[:location])
      assistance_requests = assistance_requests.for_location(location)
    end

    assistance_requests = assistance_requests.between_dates(params[:from], params[:to]) if params[:from].present? && params[:to].present? 
    assistance_requests = assistance_requests.for_program(params[:program_id]) if params[:program_id].present?
    assistance_requests = assistance_requests.for_cohort(params[:cohort_id]) if params[:cohort_id].present?

    assistance_requests.order created_at: :desc

    csv_data = CSV.generate do |csv|
      csv << csv_header
      assistance_requests.find_each do |ar|
        csv << get_csv_data(ar)
      end
    end

    send_data csv_data, filename: "assistance_requests.csv"
  end

  private

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
      "Student Notes", 
    ]
  end

  def get_csv_data(ar)
    [
      ar.created_at,
      !ar.canceled_at.nil?,
      ar.type,
      ar.reason,
      ar.cohort.name,
      ar.cohort.program.name,
      ar.day,
      ar.assistance.try(:assistor_id),
      ar.assistance.try(:assistor).try(:full_name),
      ar.assistance.try(:assistee_id),
      ar.assistance.try(:assistee).try(:full_name),
      ar.assistance.try(:start_at),
      ar.assistance.try(:end_at),
      ar.assistance.try(:activity_id),
      ar.assistance.try(:activity).try(:name),
      ar.assistance.try(:rating),
      ar.assistance.try(:notes),
      ar.assistance.try(:student_notes) 
    ]
  end
end
