class CsvEndpoint::FeedbacksController < CsvEndpoint::BaseController

  def index
    feedbacks = Feedback

    if params[:location].present?
      location = Location.find_by(name: params[:location])
      feedbacks = feedbacks.filter_by_student_location(location)
    end

    feedbacks = feedbacks.filter_by_start_date(params[:from]) if params[:from].present?
    feedbacks = feedbacks.filter_by_end_date(params[:to]) if params[:to].present?
    feedbacks = feedbacks.filter_by_program(params[:program_id]) if params[:program_id].present?
    feedbacks = feedbacks.filter_by_cohort(params[:cohort_id]) if params[:cohort_id].present?

    feedbacks.order created_at: :desc

    csv_data = CSV.generate do |csv|
      csv << csv_header
      feedbacks.find_each do |f|
        csv << get_csv_data(f)
      end
    end

    send_data csv_data, filename: "feedbacks.csv"
  end

  private

  def csv_header
    [
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

  def get_csv_data(f)
    [
      f.created_at,
      f.feedbackable_type,
      f.feedbackable_id,
      f.teacher_id,
      f.teacher.try(:full_name),
      f.student_id,
      f.student.try(:full_name),
      f.rating,
      f.technical_rating,
      f.style_rating,
      f.notes
    ]
  end

end
