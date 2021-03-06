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

ActiveRecord::Schema.define(version: 20200528171754) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assistance_requests", force: :cascade do |t|
    t.jsonb    "requestor"
    t.jsonb    "request"
    t.datetime "start_at"
    t.integer  "assistance_id"
    t.integer  "compass_instance_id"
    t.datetime "canceled_at"
    t.string   "type"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["assistance_id"], name: "index_assistance_requests_on_assistance_id", using: :btree
    t.index ["compass_instance_id"], name: "index_assistance_requests_on_compass_instance_id", using: :btree
  end

  create_table "assistances", force: :cascade do |t|
    t.string   "assistor_uid"
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating"
    t.text     "student_notes"
    t.boolean  "flag"
    t.string   "conference_link"
    t.string   "conference_type"
    t.string   "resource_type"
    t.index ["assistor_uid"], name: "index_assistances_on_assistor_uid", using: :btree
  end

  create_table "compass_instances", force: :cascade do |t|
    t.string "name"
    t.jsonb  "settings"
    t.string "database"
    t.string "type"
    t.string "key"
    t.string "secret"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "technical_rating"
    t.integer  "style_rating"
    t.text     "notes"
    t.integer  "feedbackable_id"
    t.string   "feedbackable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "rating"
  end

  create_table "queue_tasks", force: :cascade do |t|
    t.string   "assistor_uid"
    t.integer  "assistance_request_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.datetime "start_at"
    t.index ["assistance_request_id"], name: "index_queue_tasks_on_assistance_request_id", using: :btree
  end

  create_table "routing_scores", force: :cascade do |t|
    t.string   "assistor_uid"
    t.integer  "assistance_request_id"
    t.jsonb    "summary"
    t.float    "total"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["assistance_request_id"], name: "index_routing_scores_on_assistance_request_id", using: :btree
  end

  create_table "user_status_logs", force: :cascade do |t|
    t.string   "user_uid"
    t.datetime "created_at", null: false
    t.string   "status"
  end

  create_table "webhooks", force: :cascade do |t|
    t.integer  "compass_instance_id"
    t.string   "resource_type"
    t.string   "model"
    t.string   "action"
    t.string   "url"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["compass_instance_id"], name: "index_webhooks_on_compass_instance_id", using: :btree
  end

  add_foreign_key "assistance_requests", "assistances"
  add_foreign_key "assistance_requests", "compass_instances"
  add_foreign_key "queue_tasks", "assistance_requests"
  add_foreign_key "routing_scores", "assistance_requests"
  add_foreign_key "webhooks", "compass_instances"
end
