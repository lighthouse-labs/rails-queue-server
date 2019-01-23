class CsvEndpoint::FeedbacksController < CsvEndpoint::BaseController

  def index
    feedbacks = get_joined_model
    feedbacks = feedbacks.select get_select_fields
    feedbacks = add_where_clauses feedbacks
    feedbacks = feedbacks.order created_at: :desc

    pg = ActiveRecord::Base.connection.instance_variable_get(:@connection)
    pg.send_query(feedbacks.to_sql)
    pg.set_single_row_mode

    csv_data = CSV.generate do |csv|
      csv << csv_header
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

  def csv_header
    [
      "ID",
      "Created_at",
      "Feedback Type",
      "Feedbackable ID",
      "Mentor ID",
      "Mentor Name",
      "Student ID",
      "Student Name",
      "Rating",
      "Technical Rating",
      "Style Rating",
      "Notes"
    ]
  end

  def get_select_fields
    [
      "feedbacks.id",
      "feedbacks.created_at",
      "feedbacks.feedbackable_type",
      "feedbacks.feedbackable_id",
      "teachers.id",
      "teachers.first_name || ' ' || teachers.last_name",
      "students.id",
      "students.first_name || ' ' || students.last_name",
      "feedbacks.rating",
      "feedbacks.technical_rating",
      "feedbacks.style_rating",
      "feedbacks.notes"
    ]
  end

end
