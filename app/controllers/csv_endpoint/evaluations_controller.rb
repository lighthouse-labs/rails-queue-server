class CsvEndpoint::EvaluationsController < CsvEndpoint::BaseController

  def index
    filtered_field_mapping = get_field_mappings(params[:requested_fields])

    evaluations = get_joined_model
    evaluations = evaluations.select get_select_fields(filtered_field_mapping)
    evaluations = add_where_clauses evaluations
    evaluations = evaluations.order created_at: :desc

    pg = ActiveRecord::Base.connection.instance_variable_get(:@connection)
    pg.send_query(evaluations.to_sql)
    pg.set_single_row_mode

    csv_data = CSV.generate do |csv|
      csv << csv_header(filtered_field_mapping)
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

    evaluations = evaluations.exclude_autocomplete if params[:exclude_autocomplete].present?

    evaluations = evaluations.after_date(params[:from]) if params[:from].present?
    evaluations = evaluations.before_date(params[:to]) if params[:to].present?
    evaluations = evaluations.for_project(params[:project_id]) if params[:project_id].present?
  end

  def get_joined_model
    evaluations = Evaluation.joins("LEFT OUTER JOIN sections projects ON evaluations.project_id = projects.id")
    evaluations = evaluations.joins("LEFT OUTER JOIN users students ON evaluations.student_id = students.id")
    evaluations = evaluations.joins("LEFT OUTER JOIN users teachers ON evaluations.teacher_id = teachers.id")
    evaluations
  end

  def field_mapping_arr
    {
      id:              { statement: "evaluations.id", header: "ID" },
      project_id:      { statement: "evaluations.project_id", header: "Project ID" },
      project_name:    { statement: "projects.name", header: "Project Name" },
      student_id:      { statement: "evaluations.student_id", header: "Student Name" },
      student_name:    { statement: "students.first_name || ' ' || students.last_name", header: "Student Name" },
      evaluator_id:    { statement: "evaluations.teacher_id", header: "Evaluator ID" },
      evaluator_name:  { statement: "teachers.first_name || ' ' || teachers.last_name", header: "Evaluator Name" },
      evaluator_email: { statement: "teachers.email", header: "Evaluator Email" },
      state:           { statement: "evaluations.state", header: "State" },
      created_at:      { statement: "evaluations.created_at", header: "Created At" },
      started_at:      { statement: "evaluations.started_at", header: "Started At" },
      completed_at:    { statement: "evaluations.completed_at", header: "Completed At" },
      cancelled_at:    { statement: "evaluations.cancelled_at", header: "Cancelled At" },
      due_at:          { statement: "evaluations.due", header: "Due At" },
      final_score:     { statement: "evaluations.final_score", header: "Final Score" },
      resubmission:    { statement: "evaluations.resubmission", header: "Resubmission?" },
      student_notes:   { statement: "evaluations.student_notes", header: "Student Notes" },
      teacher_notes:   { statement: "evaluations.teacher_notes", header: "Teacher Notes" }
    }
  end

end
