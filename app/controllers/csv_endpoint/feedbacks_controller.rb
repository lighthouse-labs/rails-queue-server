class CsvEndpoint::FeedbacksController < CsvEndpoint::BaseController

  def index
    filtered_field_mapping = get_field_mappings(params[:requested_fields])

    feedbacks = get_joined_model
    feedbacks = feedbacks.select get_select_fields(filtered_field_mapping)
    feedbacks = add_where_clauses feedbacks
    feedbacks = feedbacks.order created_at: :desc

    pg = ActiveRecord::Base.connection.instance_variable_get(:@connection)
    pg.send_query(feedbacks.to_sql)
    pg.set_single_row_mode

    csv_data = CSV.generate do |csv|
      csv << csv_header(filtered_field_mapping)
      pg.get_result.stream_each_row do |row|
        csv << row
      end
    end

    send_data csv_data, filename: "feedbacks.csv"
  end

  private

  def add_where_clauses(feedbacks)
    if params[:location].present?
      location = Location.find_by(name: params[:location])
      feedbacks = feedbacks.filter_by_student_location(location)
    end

    feedbacks = feedbacks.filter_by_start_date_no_location(params[:from]) if params[:from].present?
    feedbacks = feedbacks.filter_by_end_date_no_location(params[:to]) if params[:to].present?
    feedbacks = feedbacks.filter_by_program(params[:program_id]) if params[:program_id].present?
    feedbacks = feedbacks.filter_by_cohort(params[:cohort_id]) if params[:cohort_id].present?

    feedbacks
  end

  def get_joined_model
    feedbacks = Feedback.joins("LEFT OUTER JOIN users students ON feedbacks.student_id = students.id")
    feedbacks = feedbacks.joins("LEFT OUTER JOIN users teachers ON feedbacks.teacher_id = teachers.id")
  end

  def field_mapping_arr
    {
      id:               { statement: "feedbacks.id", header: "ID" },
      created_at:       { statement: "feedbacks.created_at", header: "Created At" },
      type:             { statement: "feedbacks.feedbackable_type", header: "Feedback Type" },
      feedbackable_id:  { statement: "feedbacks.feedbackable_id", header: "Feedbackable ID" },
      mentor_id:        { statement: "teachers.id", header: "Mentor ID" },
      mentor_name:      { statement: "teachers.first_name || ' ' || teachers.last_name", header: "Mentor Name" },
      student_id:       { statement: "students.id", header: "Student ID" },
      student_name:     { statement: "students.first_name || ' ' || students.last_name", header: "Student Name" },
      rating:           { statement: "feedbacks.rating", header: "Rating" },
      notes:            { statement: "feedbacks.notes", header: "Notes" }
    }
  end

end
