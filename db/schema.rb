# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160817205339) do

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
    t.boolean  "allow_feedback",        default: true
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
  end

  add_index "activities", ["content_repository_id"], name: "index_activities_on_content_repository_id", using: :btree
  add_index "activities", ["quiz_id"], name: "index_activities_on_quiz_id", using: :btree
  add_index "activities", ["sequence"], name: "index_activities_on_sequence", using: :btree
  add_index "activities", ["start_time"], name: "index_activities_on_start_time", using: :btree
  add_index "activities", ["uuid"], name: "index_activities_on_uuid", unique: true, using: :btree

  create_table "activity_feedbacks", force: :cascade do |t|
    t.integer  "activity_id"
    t.integer  "user_id"
    t.integer  "sentiment"
    t.integer  "rating"
    t.text     "detail"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "activity_feedbacks", ["activity_id"], name: "index_activity_feedbacks_on_activity_id", using: :btree
  add_index "activity_feedbacks", ["user_id"], name: "index_activity_feedbacks_on_user_id", using: :btree

  create_table "activity_messages", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "cohort_id"
    t.integer  "activity_id"
    t.string   "kind",          limit: 50
    t.string   "day",           limit: 5
    t.string   "subject",       limit: 1000
    t.text     "body"
    t.text     "teacher_notes"
    t.boolean  "for_students"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activity_messages", ["activity_id"], name: "index_activity_messages_on_activity_id", using: :btree
  add_index "activity_messages", ["cohort_id"], name: "index_activity_messages_on_cohort_id", using: :btree
  add_index "activity_messages", ["day"], name: "index_activity_messages_on_day", using: :btree
  add_index "activity_messages", ["user_id"], name: "index_activity_messages_on_user_id", using: :btree

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
  end

  add_index "activity_submissions", ["activity_id"], name: "index_activity_submissions_on_activity_id", using: :btree
  add_index "activity_submissions", ["user_id"], name: "index_activity_submissions_on_user_id", using: :btree

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
  end

  add_index "answers", ["option_id"], name: "index_answers_on_option_id", using: :btree
  add_index "answers", ["quiz_submission_id"], name: "index_answers_on_quiz_submission_id", using: :btree

  create_table "assistance_requests", force: :cascade do |t|
    t.integer  "requestor_id"
    t.integer  "assistor_id"
    t.datetime "start_at"
    t.datetime "assistance_start_at"
    t.datetime "assistance_end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assistance_id"
    t.datetime "canceled_at"
    t.string   "type"
    t.integer  "activity_submission_id"
    t.text     "reason"
    t.integer  "activity_id"
    t.integer  "original_activity_submission_id"
  end

  add_index "assistance_requests", ["activity_id"], name: "index_assistance_requests_on_activity_id", using: :btree
  add_index "assistance_requests", ["activity_submission_id"], name: "index_assistance_requests_on_activity_submission_id", using: :btree

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
  end

  add_index "assistances", ["activity_id"], name: "index_assistances_on_activity_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "uuid"
  end

  add_index "categories", ["uuid"], name: "index_categories_on_uuid", unique: true, using: :btree

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
  end

  add_index "cohorts", ["program_id"], name: "index_cohorts_on_program_id", using: :btree

  create_table "content_repositories", force: :cascade do |t|
    t.string   "github_username"
    t.string   "github_repo"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "last_sha"
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
  end

  add_index "deployments", ["content_repository_id"], name: "index_deployments_on_content_repository_id", using: :btree

  create_table "evaluation_transitions", force: :cascade do |t|
    t.string   "to_state",                     null: false
    t.text     "metadata",      default: "{}"
    t.integer  "sort_key",                     null: false
    t.integer  "evaluation_id",                null: false
    t.boolean  "most_recent",                  null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "evaluation_transitions", ["evaluation_id", "most_recent"], name: "index_evaluation_transitions_parent_most_recent", unique: true, where: "most_recent", using: :btree
  add_index "evaluation_transitions", ["evaluation_id", "sort_key"], name: "index_evaluation_transitions_parent_sort", unique: true, using: :btree

  create_table "evaluations", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "student_id"
    t.integer  "teacher_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "github_url"
    t.text     "teacher_notes"
    t.string   "state",         default: "pending"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.text     "student_notes"
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
  end

  add_index "item_outcomes", ["item_id"], name: "index_item_outcomes_on_item_id", using: :btree

  create_table "locations", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "calendar"
    t.string   "timezone"
    t.boolean  "has_code_reviews", default: true
  end

  create_table "options", force: :cascade do |t|
    t.text     "answer"
    t.text     "explanation"
    t.boolean  "correct"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "question_id"
  end

  add_index "options", ["question_id"], name: "index_options_on_question_id", using: :btree

  create_table "outcome_results", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "outcome_id"
    t.string   "source_name"
    t.integer  "source_id"
    t.string   "source_type"
    t.float    "rating"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "outcome_results", ["outcome_id"], name: "index_outcome_results_on_outcome_id", using: :btree
  add_index "outcome_results", ["source_type", "source_id"], name: "index_outcome_results_on_source_type_and_source_id", using: :btree
  add_index "outcome_results", ["user_id"], name: "index_outcome_results_on_user_id", using: :btree

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
  end

  add_index "outcomes", ["skill_id"], name: "index_outcomes_on_skill_id", using: :btree
  add_index "outcomes", ["uuid"], name: "index_outcomes_on_uuid", unique: true, using: :btree

  create_table "programs", force: :cascade do |t|
    t.string   "name"
    t.text     "lecture_tips"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "recordings_folder"
    t.string   "recordings_bucket"
    t.string   "tag"
  end

  create_table "questions", force: :cascade do |t|
    t.text     "question"
    t.boolean  "active"
    t.integer  "created_by_user_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "outcome_id"
    t.string   "uuid"
  end

  add_index "questions", ["outcome_id"], name: "index_questions_on_outcome_id", using: :btree
  add_index "questions", ["uuid"], name: "index_questions_on_uuid", unique: true, using: :btree

  create_table "questions_quizzes", id: false, force: :cascade do |t|
    t.integer "question_id"
    t.integer "quiz_id"
  end

  add_index "questions_quizzes", ["question_id"], name: "index_questions_quizzes_on_question_id", using: :btree
  add_index "questions_quizzes", ["quiz_id"], name: "index_questions_quizzes_on_quiz_id", using: :btree

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
  end

  add_index "quiz_submissions", ["quiz_id"], name: "index_quiz_submissions_on_quiz_id", using: :btree
  add_index "quiz_submissions", ["user_id"], name: "index_quiz_submissions_on_user_id", using: :btree

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
  end

  add_index "sections", ["content_repository_id"], name: "index_sections_on_content_repository_id", using: :btree
  add_index "sections", ["uuid"], name: "index_sections_on_uuid", unique: true, using: :btree

  create_table "skills", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "category_id"
    t.string   "uuid"
  end

  add_index "skills", ["category_id"], name: "index_skills_on_category_id", using: :btree
  add_index "skills", ["uuid"], name: "index_skills_on_uuid", unique: true, using: :btree

  create_table "streams", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.string   "wowza_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_activity_outcomes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "activity_outcome_id"
    t.float    "rating"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "user_activity_outcomes", ["activity_outcome_id"], name: "index_user_activity_outcomes_on_activity_outcome_id", using: :btree
  add_index "user_activity_outcomes", ["user_id"], name: "index_user_activity_outcomes_on_user_id", using: :btree

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
    t.boolean  "remote",                 default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "code_review_percent",    default: 80
    t.boolean  "admin",                  default: false, null: false
    t.string   "company_name"
    t.string   "company_url"
    t.text     "bio"
    t.string   "quirky_fact"
    t.string   "specialties"
    t.integer  "location_id"
    t.boolean  "on_duty",                default: false
    t.integer  "mentor_id"
    t.boolean  "mentor",                 default: false
  end

  add_index "users", ["cohort_id"], name: "index_users_on_cohort_id", using: :btree

  add_foreign_key "activities", "quizzes"
  add_foreign_key "activity_feedbacks", "activities"
  add_foreign_key "activity_feedbacks", "users"
  add_foreign_key "answers", "options"
  add_foreign_key "answers", "quiz_submissions"
  add_foreign_key "deployments", "content_repositories"
  add_foreign_key "options", "questions"
  add_foreign_key "outcome_results", "outcomes"
  add_foreign_key "outcome_results", "users"
  add_foreign_key "questions", "outcomes"
  add_foreign_key "quiz_submissions", "quizzes"
  add_foreign_key "sections", "content_repositories"
  add_foreign_key "user_activity_outcomes", "item_outcomes", column: "activity_outcome_id"
  add_foreign_key "user_activity_outcomes", "users"
end
