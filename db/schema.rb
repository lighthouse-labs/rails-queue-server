# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180601004248) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string   "name"
    t.integer  "start_time"
    t.integer  "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "day"
    t.string   "gist_url"
    t.text     "instructions"
    t.text     "teacher_notes"
    t.string   "file_name"
    t.boolean  "allow_submissions",     default: true
    t.string   "media_filename"
    t.string   "revisions_gistid"
    t.integer  "code_review_percent",   default: 60
    t.integer  "quiz_id"
    t.integer  "content_repository_id"
    t.string   "content_file_path"
    t.boolean  "remote_content"
    t.integer  "section_id"
    t.boolean  "evaluates_code"
    t.string   "uuid"
    t.text     "initial_code"
    t.text     "test_code"
    t.integer  "sequence"
    t.boolean  "stretch"
    t.boolean  "archived"
    t.float    "average_rating"
    t.integer  "average_time_spent"
    t.boolean  "homework"
    t.index ["content_repository_id"], name: "index_activities_on_content_repository_id", using: :btree
    t.index ["quiz_id"], name: "index_activities_on_quiz_id", using: :btree
    t.index ["sequence"], name: "index_activities_on_sequence", using: :btree
    t.index ["start_time"], name: "index_activities_on_start_time", using: :btree
    t.index ["uuid"], name: "index_activities_on_uuid", unique: true, using: :btree
  end

  create_table "activity_feedbacks", force: :cascade do |t|
    t.integer  "activity_id"
    t.integer  "user_id"
    t.integer  "sentiment"
    t.integer  "rating"
    t.text     "detail"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["activity_id"], name: "index_activity_feedbacks_on_activity_id", using: :btree
    t.index ["user_id"], name: "index_activity_feedbacks_on_user_id", using: :btree
  end

  create_table "activity_messages", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "cohort_id"
    t.integer  "activity_id"
    t.string   "kind",          limit: 50
    t.string   "day",           limit: 5
    t.string   "subject",       limit: 1000
    t.text     "body"
    t.text     "teacher_notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["activity_id"], name: "index_activity_messages_on_activity_id", using: :btree
    t.index ["cohort_id"], name: "index_activity_messages_on_cohort_id", using: :btree
    t.index ["day"], name: "index_activity_messages_on_day", using: :btree
    t.index ["user_id"], name: "index_activity_messages_on_user_id", using: :btree
  end

  create_table "activity_submissions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "activity_id"
    t.datetime "completed_at"
    t.string   "github_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "finalized",               default: false
    t.text     "code_evaluation_results"
    t.integer  "time_spent"
    t.text     "note"
    t.integer  "cohort_id"
    t.index ["activity_id"], name: "index_activity_submissions_on_activity_id", using: :btree
    t.index ["cohort_id"], name: "index_activity_submissions_on_cohort_id", using: :btree
    t.index ["user_id"], name: "index_activity_submissions_on_user_id", using: :btree
  end

  create_table "activity_tests", force: :cascade do |t|
    t.text    "test"
    t.integer "activity_id"
    t.text    "initial_code"
  end

  create_table "answers", force: :cascade do |t|
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "option_id"
    t.integer  "quiz_submission_id"
    t.index ["option_id"], name: "index_answers_on_option_id", using: :btree
    t.index ["quiz_submission_id"], name: "index_answers_on_quiz_submission_id", using: :btree
  end

  create_table "assistance_requests", force: :cascade do |t|
    t.integer  "requestor_id"
    t.integer  "assistor_id"
    t.datetime "start_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assistance_id"
    t.datetime "canceled_at"
    t.string   "type"
    t.integer  "activity_submission_id"
    t.text     "reason"
    t.integer  "activity_id"
    t.integer  "original_activity_submission_id"
    t.integer  "cohort_id"
    t.string   "day"
    t.integer  "assistor_location_id"
    t.index ["activity_id"], name: "index_assistance_requests_on_activity_id", using: :btree
    t.index ["activity_submission_id"], name: "index_assistance_requests_on_activity_submission_id", using: :btree
    t.index ["assistor_location_id"], name: "index_assistance_requests_on_assistor_location_id", using: :btree
    t.index ["cohort_id"], name: "index_assistance_requests_on_cohort_id", using: :btree
  end

  create_table "assistances", force: :cascade do |t|
    t.integer  "assistor_id"
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assistee_id"
    t.integer  "rating"
    t.text     "student_notes"
    t.boolean  "imported",      default: false
    t.integer  "activity_id"
    t.integer  "cohort_id"
    t.string   "day"
    t.boolean  "flag"
    t.integer  "secs_in_queue"
    t.index ["activity_id"], name: "index_assistances_on_activity_id", using: :btree
    t.index ["cohort_id"], name: "index_assistances_on_cohort_id", using: :btree
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "uuid"
    t.index ["uuid"], name: "index_categories_on_uuid", unique: true, using: :btree
  end

  create_table "code_reviews", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cohorts", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_date"
    t.string   "code"
    t.string   "teacher_email_group"
    t.integer  "program_id"
    t.integer  "location_id"
    t.boolean  "limited"
    t.string   "weekdays"
    t.text     "disable_queue_days",     default: [], null: false, array: true
    t.boolean  "local_assistance_queue"
    t.index ["program_id"], name: "index_cohorts_on_program_id", using: :btree
  end

  create_table "content_repositories", force: :cascade do |t|
    t.string   "github_username"
    t.string   "github_repo"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "last_sha"
    t.string   "github_branch",   default: "master"
  end

  create_table "curriculum_breaks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "reason"
    t.date     "starts_on"
    t.integer  "num_weeks"
    t.integer  "cohort_id"
    t.index ["cohort_id"], name: "index_curriculum_breaks_on_cohort_id", using: :btree
  end

  create_table "day_feedbacks", force: :cascade do |t|
    t.string   "mood"
    t.string   "title"
    t.text     "text"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "day"
    t.datetime "archived_at"
    t.integer  "archived_by_user_id"
    t.text     "notes"
  end

  create_table "day_infos", force: :cascade do |t|
    t.string   "day"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deployments", force: :cascade do |t|
    t.integer  "content_repository_id"
    t.string   "sha"
    t.string   "status",                default: "started"
    t.string   "log_file"
    t.string   "summary_file"
    t.datetime "completed_at"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.text     "error_message"
    t.string   "branch"
    t.index ["content_repository_id"], name: "index_deployments_on_content_repository_id", using: :btree
  end

  create_table "evaluation_transitions", force: :cascade do |t|
    t.string   "to_state",                     null: false
    t.text     "metadata",      default: "{}"
    t.integer  "sort_key",                     null: false
    t.integer  "evaluation_id",                null: false
    t.boolean  "most_recent",                  null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["evaluation_id", "most_recent"], name: "index_evaluation_transitions_parent_most_recent", unique: true, where: "most_recent", using: :btree
    t.index ["evaluation_id", "sort_key"], name: "index_evaluation_transitions_parent_sort", unique: true, using: :btree
  end

  create_table "evaluations", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "student_id"
    t.integer  "teacher_id"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "github_url"
    t.text     "teacher_notes"
    t.string   "state",                default: "pending"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.text     "student_notes"
    t.datetime "cancelled_at"
    t.integer  "cohort_id"
    t.float    "final_score"
    t.string   "last_sha1"
    t.jsonb    "evaluation_rubric"
    t.text     "evaluation_guide"
    t.text     "evaluation_checklist"
    t.jsonb    "result"
    t.boolean  "resubmission"
    t.datetime "due"
    t.index ["cohort_id"], name: "index_evaluations_on_cohort_id", using: :btree
    t.index ["evaluation_rubric"], name: "index_evaluations_on_evaluation_rubric", using: :gin
    t.index ["result"], name: "index_evaluations_on_result", using: :gin
  end

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "student_id"
    t.integer  "teacher_id"
    t.integer  "technical_rating"
    t.integer  "style_rating"
    t.text     "notes"
    t.integer  "feedbackable_id"
    t.string   "feedbackable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "rating"
  end

  create_table "item_outcomes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "outcome_id"
    t.string   "item_type"
    t.integer  "item_id"
    t.index ["item_id"], name: "index_item_outcomes_on_item_id", using: :btree
  end

  create_table "locations", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "calendar"
    t.string   "timezone"
    t.boolean  "has_code_reviews",         default: true
    t.boolean  "satellite"
    t.integer  "supported_by_location_id"
    t.string   "feedback_email"
    t.string   "slack_channel"
    t.string   "slack_username"
    t.boolean  "active",                   default: true
    t.index ["supported_by_location_id"], name: "index_locations_on_supported_by_location_id", using: :btree
  end

  create_table "options", force: :cascade do |t|
    t.text     "answer"
    t.text     "explanation"
    t.boolean  "correct"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "question_id"
    t.index ["question_id"], name: "index_options_on_question_id", using: :btree
  end

  create_table "outcome_results", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "outcome_id"
    t.string   "source_name"
    t.integer  "source_id"
    t.string   "source_type"
    t.float    "rating"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["outcome_id"], name: "index_outcome_results_on_outcome_id", using: :btree
    t.index ["source_type", "source_id"], name: "index_outcome_results_on_source_type_and_source_id", using: :btree
    t.index ["user_id"], name: "index_outcome_results_on_user_id", using: :btree
  end

  create_table "outcome_skills", force: :cascade do |t|
    t.integer "outcome_id"
    t.integer "skill_id"
  end

  create_table "outcomes", force: :cascade do |t|
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "skill_id"
    t.string   "uuid"
    t.string   "taxonomy"
    t.string   "importance"
    t.index ["skill_id"], name: "index_outcomes_on_skill_id", using: :btree
    t.index ["uuid"], name: "index_outcomes_on_uuid", unique: true, using: :btree
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text     "content"
    t.string   "searchable_type"
    t.integer  "searchable_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id", using: :btree
  end

  create_table "prep_assistance_requests", force: :cascade do |t|
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "user_id"
    t.integer  "activity_id"
    t.index ["activity_id"], name: "index_prep_assistance_requests_on_activity_id", using: :btree
    t.index ["user_id"], name: "index_prep_assistance_requests_on_user_id", using: :btree
  end

  create_table "programs", force: :cascade do |t|
    t.string   "name"
    t.text     "lecture_tips"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "recordings_folder"
    t.string   "recordings_bucket"
    t.string   "tag"
    t.integer  "days_per_week"
    t.integer  "weeks"
    t.boolean  "weekends"
    t.string   "curriculum_unlocking"
    t.boolean  "has_interviews",                  default: true
    t.boolean  "has_projects",                    default: true
    t.boolean  "has_code_reviews",                default: true
    t.boolean  "display_exact_activity_duration"
    t.boolean  "prep_assistance"
    t.boolean  "has_queue",                       default: true
    t.text     "disable_queue_days",              default: [],   null: false, array: true
  end

  create_table "questions", force: :cascade do |t|
    t.text     "question"
    t.boolean  "active"
    t.integer  "created_by_user_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "outcome_id"
    t.string   "uuid"
    t.index ["outcome_id"], name: "index_questions_on_outcome_id", using: :btree
    t.index ["uuid"], name: "index_questions_on_uuid", unique: true, using: :btree
  end

  create_table "questions_quizzes", id: false, force: :cascade do |t|
    t.integer "question_id"
    t.integer "quiz_id"
    t.index ["question_id"], name: "index_questions_quizzes_on_question_id", using: :btree
    t.index ["quiz_id"], name: "index_questions_quizzes_on_quiz_id", using: :btree
  end

  create_table "quiz_submissions", force: :cascade do |t|
    t.string   "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "quiz_id"
    t.integer  "user_id"
    t.boolean  "initial"
    t.integer  "total"
    t.integer  "correct"
    t.integer  "incorrect"
    t.integer  "skipped"
    t.integer  "cohort_id"
    t.index ["cohort_id"], name: "index_quiz_submissions_on_cohort_id", using: :btree
    t.index ["quiz_id"], name: "index_quiz_submissions_on_quiz_id", using: :btree
    t.index ["user_id"], name: "index_quiz_submissions_on_user_id", using: :btree
  end

  create_table "quizzes", force: :cascade do |t|
    t.string   "day"
    t.string   "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
  end

  create_table "recordings", force: :cascade do |t|
    t.string   "file_name"
    t.datetime "recorded_at"
    t.integer  "presenter_id"
    t.integer  "cohort_id"
    t.integer  "activity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "program_id"
    t.string   "title"
    t.string   "presenter_name"
    t.string   "file_type"
  end

  create_table "sections", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "order"
    t.string   "type"
    t.string   "uuid"
    t.text     "description"
    t.string   "content_file_path"
    t.integer  "content_repository_id"
    t.string   "start_day"
    t.text     "blurb"
    t.string   "end_day"
    t.string   "image"
    t.boolean  "evaluated"
    t.string   "last_sha1"
    t.json     "evaluation_rubric"
    t.text     "evaluation_guide"
    t.text     "evaluation_checklist"
    t.text     "teacher_notes"
    t.boolean  "archived"
    t.boolean  "stretch"
    t.index ["content_repository_id"], name: "index_sections_on_content_repository_id", using: :btree
    t.index ["uuid"], name: "index_sections_on_uuid", unique: true, using: :btree
  end

  create_table "skills", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "category_id"
    t.string   "uuid"
    t.index ["category_id"], name: "index_skills_on_category_id", using: :btree
    t.index ["uuid"], name: "index_skills_on_uuid", unique: true, using: :btree
  end

  create_table "streams", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.string   "wowza_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tech_interview_questions", force: :cascade do |t|
    t.string   "uuid"
    t.integer  "tech_interview_template_id"
    t.integer  "outcome_id"
    t.integer  "sequence"
    t.text     "question"
    t.text     "answer"
    t.text     "notes"
    t.integer  "duration"
    t.boolean  "stretch"
    t.boolean  "archived"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["outcome_id"], name: "index_tech_interview_questions_on_outcome_id", using: :btree
    t.index ["tech_interview_template_id"], name: "index_tech_interview_questions_on_tech_interview_template_id", using: :btree
  end

  create_table "tech_interview_results", force: :cascade do |t|
    t.integer  "tech_interview_id"
    t.integer  "tech_interview_question_id"
    t.text     "question"
    t.text     "notes"
    t.integer  "score"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "sequence"
    t.index ["tech_interview_id"], name: "index_tech_interview_results_on_tech_interview_id", using: :btree
    t.index ["tech_interview_question_id"], name: "index_tech_interview_results_on_tech_interview_question_id", using: :btree
  end

  create_table "tech_interview_templates", force: :cascade do |t|
    t.string   "uuid"
    t.integer  "week"
    t.string   "content_file_path"
    t.integer  "content_repository_id"
    t.text     "description"
    t.text     "teacher_notes"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.boolean  "archived"
    t.index ["content_repository_id"], name: "index_tech_interview_templates_on_content_repository_id", using: :btree
  end

  create_table "tech_interviews", force: :cascade do |t|
    t.integer  "tech_interview_template_id"
    t.integer  "interviewee_id"
    t.integer  "interviewer_id"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.integer  "total_answered"
    t.integer  "total_asked"
    t.float    "average_score"
    t.text     "feedback"
    t.text     "internal_notes"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "day"
    t.integer  "articulation_score"
    t.integer  "knowledge_score"
    t.integer  "cohort_id"
    t.datetime "last_alerted_at"
    t.integer  "num_alerts",                 default: 0
    t.index ["cohort_id"], name: "index_tech_interviews_on_cohort_id", using: :btree
    t.index ["interviewee_id"], name: "index_tech_interviews_on_interviewee_id", using: :btree
    t.index ["interviewer_id"], name: "index_tech_interviews_on_interviewer_id", using: :btree
    t.index ["tech_interview_template_id"], name: "index_tech_interviews_on_tech_interview_template_id", using: :btree
  end

  create_table "user_activity_outcomes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "activity_outcome_id"
    t.float    "rating"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["activity_outcome_id"], name: "index_user_activity_outcomes_on_activity_outcome_id", using: :btree
    t.index ["user_id"], name: "index_user_activity_outcomes_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone_number"
    t.string   "twitter"
    t.string   "skype"
    t.string   "uid"
    t.string   "token"
    t.boolean  "completed_registration"
    t.string   "github_username"
    t.string   "avatar_url"
    t.integer  "cohort_id"
    t.string   "type"
    t.string   "custom_avatar"
    t.string   "unlocked_until_day"
    t.datetime "last_assisted_at"
    t.datetime "deactivated_at"
    t.string   "slack"
    t.boolean  "remote",                    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "code_review_percent",       default: 80
    t.boolean  "admin",                     default: false, null: false
    t.string   "company_name"
    t.string   "company_url"
    t.text     "bio"
    t.string   "quirky_fact"
    t.string   "specialties"
    t.integer  "location_id"
    t.boolean  "on_duty",                   default: false
    t.integer  "mentor_id"
    t.boolean  "mentor",                    default: false
    t.integer  "initial_cohort_id"
    t.string   "auth_token",                default: "",    null: false
    t.boolean  "suppress_tech_interviews"
    t.float    "cohort_assistance_average"
    t.index ["auth_token"], name: "index_users_on_auth_token", using: :btree
    t.index ["cohort_id"], name: "index_users_on_cohort_id", using: :btree
    t.index ["initial_cohort_id"], name: "index_users_on_initial_cohort_id", using: :btree
  end

  create_table "work_module_items", force: :cascade do |t|
    t.string   "uuid",           null: false
    t.integer  "work_module_id"
    t.integer  "activity_id"
    t.integer  "order"
    t.boolean  "archived"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.boolean  "stretch"
    t.index ["activity_id"], name: "index_work_module_items_on_activity_id", using: :btree
    t.index ["uuid"], name: "index_work_module_items_on_uuid", unique: true, using: :btree
    t.index ["work_module_id"], name: "index_work_module_items_on_work_module_id", using: :btree
  end

  create_table "work_modules", force: :cascade do |t|
    t.string   "uuid",              null: false
    t.string   "name",              null: false
    t.string   "slug"
    t.integer  "workbook_id"
    t.integer  "order"
    t.boolean  "archived"
    t.string   "content_file_path"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["slug"], name: "index_work_modules_on_slug", unique: true, using: :btree
    t.index ["uuid"], name: "index_work_modules_on_uuid", unique: true, using: :btree
    t.index ["workbook_id"], name: "index_work_modules_on_workbook_id", using: :btree
  end

  create_table "workbooks", force: :cascade do |t|
    t.string   "uuid",                            null: false
    t.string   "name",                            null: false
    t.string   "slug"
    t.string   "content_file_path"
    t.integer  "content_repository_id"
    t.boolean  "archived"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "unlock_on_day",         limit: 5
    t.index ["content_repository_id"], name: "index_workbooks_on_content_repository_id", using: :btree
    t.index ["slug"], name: "index_workbooks_on_slug", unique: true, using: :btree
    t.index ["uuid"], name: "index_workbooks_on_uuid", unique: true, using: :btree
  end

  add_foreign_key "activities", "quizzes"
  add_foreign_key "activity_feedbacks", "activities"
  add_foreign_key "activity_feedbacks", "users"
  add_foreign_key "answers", "options"
  add_foreign_key "answers", "quiz_submissions"
  add_foreign_key "curriculum_breaks", "cohorts"
  add_foreign_key "deployments", "content_repositories"
  add_foreign_key "options", "questions"
  add_foreign_key "outcome_results", "outcomes"
  add_foreign_key "outcome_results", "users"
  add_foreign_key "prep_assistance_requests", "activities"
  add_foreign_key "prep_assistance_requests", "users"
  add_foreign_key "questions", "outcomes"
  add_foreign_key "quiz_submissions", "quizzes"
  add_foreign_key "sections", "content_repositories"
  add_foreign_key "tech_interview_questions", "outcomes"
  add_foreign_key "tech_interview_questions", "tech_interview_templates"
  add_foreign_key "tech_interview_results", "tech_interview_questions"
  add_foreign_key "tech_interview_results", "tech_interviews"
  add_foreign_key "tech_interviews", "cohorts"
  add_foreign_key "tech_interviews", "tech_interview_templates"
  add_foreign_key "user_activity_outcomes", "item_outcomes", column: "activity_outcome_id"
  add_foreign_key "user_activity_outcomes", "users"
  add_foreign_key "work_module_items", "activities"
  add_foreign_key "work_module_items", "work_modules"
  add_foreign_key "work_modules", "workbooks"
  add_foreign_key "workbooks", "content_repositories"
end
