class CsvEndpoint::TechInterviewsController < CsvEndpoint::BaseController

  def index
    filtered_field_mapping = get_field_mappings(params[:requested_fields])

    tech_interviews = get_joined_model
    tech_interviews = tech_interviews.select get_select_fields(filtered_field_mapping)
    tech_interviews = add_where_clauses tech_interviews
    tech_interviews = tech_interviews.order created_at: :desc

    pg = ActiveRecord::Base.connection.instance_variable_get(:@connection)
    pg.send_query(tech_interviews.to_sql)
    pg.set_single_row_mode

    csv_data = CSV.generate do |csv|
      csv << csv_header(filtered_field_mapping)
      pg.get_result.stream_each_row do |row|
        csv << row
      end
    end

    send_data csv_data, filename: "tech_interviews.csv"
  end

  private

  def add_where_clauses(tech_interviews)
    if params[:location].present?
      location = Location.find_by(name: params[:location])
      tech_interviews = tech_interviews.for_locations([location])
    end

    if params[:from].present? || params[:to].present?
      params[:to] = Date.parse(params[:to]) if params[:to].present? && params[:from].blank?
      params[:to] ||= Date.today
      params[:from] ||= params[:to] - 1.year

      tech_interviews = tech_interviews.between_dates(params[:from], params[:to])
    end

    tech_interviews = tech_interviews.for_program(params[:program_id]) if params[:program_id].present?
    tech_interviews = tech_interviews.for_cohort(params[:cohort_id]) if params[:cohort_id].present?

    tech_interviews
  end

  def get_joined_model
    tech_interviews = TechInterview.joins("LEFT OUTER JOIN cohorts ON tech_interviews.cohort_id = cohorts.id")
    tech_interviews = tech_interviews.joins("LEFT OUTER JOIN programs ON cohorts.program_id = programs.id")
    tech_interviews = tech_interviews.joins("LEFT OUTER JOIN users interviewer ON tech_interviews.interviewer_id = interviewer.id")
    tech_interviews = tech_interviews.joins("LEFT OUTER JOIN users interviewee ON tech_interviews.interviewee_id = interviewee.id")
  end

  def field_mapping_arr
    {
      id:                    { statement: "tech_interviews.id", header: "ID" },
      created_at:            { statement: "tech_interviews.created_at", header: "Interview Created At" },
      started_at:           { statement: "tech_interviews.started_at", header: "Interview Started At" },
      completed_at:           { statement: "tech_interviews.completed_at", header: "Interview Completed At" },
      interview_template_id:           { statement: "tech_interviews.tech_interview_template_id", header: "Interview Template ID" },
      total_asked:           { statement: "tech_interviews.total_asked", header: "Number of Questions Asked" },
      total_answered:           { statement: "tech_interviews.total_answered", header: "Number of Questions Answered" },
      average_score:           { statement: "tech_interviews.average_score", header: "Average Score" },
      articulation_score:           { statement: "tech_interviews.articulation_score", header: "Articulation Score" },
      knowledge_score:           { statement: "tech_interviews.knowledge_score", header: "Knowledge Score" },
      feedback:            { statement: "tech_interviews.feedback", header: "Feedback" },
      internal_notes:            { statement: "tech_interviews.internal_notes", header: "Internal Notes" },
      cohort_name:           { statement: "cohorts.name", header: "Cohort Name" },
      program_name:          { statement: "programs.name", header: "Program Name" },
      cohort_day:            { statement: "tech_interviews.day", header: "Cohort Day" },
      mentor_id:             { statement: "interviewer.id", header: "Mentor ID" },
      mentor_name:           { statement: "interviewer.first_name || ' ' || interviewer.last_name", header: "Mentor Name" },
      student_id:            { statement: "interviewee.id", header: "Student ID" },
      student_name:          { statement: "interviewee.first_name || ' ' || interviewee.last_name", header: "Student Name" },
    }
  end

end
