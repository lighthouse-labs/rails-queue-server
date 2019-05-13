class CsvEndpoint::EvaluationsController < CsvEndpoint::BaseController

  def index
    evaluations = get_joined_model
    evaluations = evaluations.select get_select_fields
    evaluations = add_where_clauses evaluations
    evaluations = evaluations.order created_at: :desc

    pg = ActiveRecord::Base.connection.instance_variable_get(:@connection)
    pg.send_query(evaluations.to_sql)
    pg.set_single_row_mode

    csv_data = CSV.generate do |csv|
      csv << csv_header
      pg.get_result.stream_each_row do |row|
        csv << row
      end
    end

    send_data csv_data, filename: "evaluations.csv"
  end

  private

  def add_where_clauses(evaluations)
    if params[:location].present?
      location = Location.find_by(name: params[:location])
      evaluations = evaluations.student_cohort_in_location(location)
    end

    evaluations = evaluations.after_date(params[:from]) if params[:from].present?
    evaluations = evaluations.before_date(params[:to]) if params[:to].present?
    evaluations = evaluations.for_project(params[:project_id]) if params[:project_id].present?

    evaluations
  end

  def get_joined_model
    evaluations = Evaluation.scoped
    evaluations
  end

  def csv_header
    [
      "ID",
      "Project ID",
      "Student ID",
      "Teacher ID",
      "Created At",
      "Started At",
      "Completed At",
      "Cancelled At",
      "Final Score",
      "Resubmission?",
      "Due At",
      "Student Notes",
      "Teacher Notes"
    ]
  end

  def get_select_fields
    [
      "evaluations.id",
      "evaluations.project_id",
      "evaluations.student_id",
      "evaluations.teacher_id",
      "evaluations.created_at",
      "evaluations.state",
      "evaluations.started_at",
      "evaluations.completed_at",
      "evaluations.cancelled_at",
      "evaluations.final_score",
      "evaluations.resubmission",
      "evaluations.due",
      "evaluations.student_notes",
      "evaluations.teacher_notes"
    ]
  end

end
