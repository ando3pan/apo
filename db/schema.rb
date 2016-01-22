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

ActiveRecord::Schema.define(version: 20160122203607) do

  create_table "attendances", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.boolean  "attended"
    t.boolean  "flaked"
    t.boolean  "chair"
    t.boolean  "can_drive"
    t.boolean  "drove"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "past_quarter",  default: false
    t.datetime "quarter_ended"
  end

  add_index "attendances", ["event_id"], name: "index_attendances_on_event_id"
  add_index "attendances", ["user_id", "event_id"], name: "index_attendances_on_user_id_and_event_id", unique: true
  add_index "attendances", ["user_id"], name: "index_attendances_on_user_id"

  create_table "events", force: :cascade do |t|
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "location"
    t.string   "title"
    t.string   "event_type"
    t.decimal  "hours",          default: 0.0
    t.decimal  "driver_hours",   default: 0.0
    t.boolean  "flake_penalty",  default: true
    t.text     "info",           default: ""
    t.string   "distance",       default: ""
    t.string   "contact",        default: ""
    t.integer  "attendance_cap"
    t.integer  "user_id"
    t.boolean  "public",         default: true
    t.integer  "chair_id"
    t.string   "address",        default: ""
    t.boolean  "off_campus",     default: true
  end

  create_table "greensheet_sections", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title"
    t.datetime "start_time"
    t.decimal  "hours",               default: 0.0
    t.string   "chair"
    t.string   "event_type"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "original_event_type", default: "",  null: false
    t.integer  "event_id",            default: 0,   null: false
  end

  create_table "greensheet_texts", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "text"
    t.string   "title"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "settings", force: :cascade do |t|
    t.datetime "fall_quarter",   default: '2016-01-22 12:45:21', null: false
    t.datetime "winter_quarter", default: '2016-01-22 12:45:21', null: false
    t.datetime "spring_quarter", default: '2016-01-22 12:45:21', null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "username",               default: "",    null: false
    t.string   "a_username",             default: "",    null: false
    t.string   "firstname",              default: "",    null: false
    t.string   "lastname",               default: "",    null: false
    t.string   "nickname",               default: "",    null: false
    t.string   "displayname",            default: "",    null: false
    t.string   "phone",                  default: "",    null: false
    t.string   "family",                 default: "",    null: false
    t.string   "line",                   default: "",    null: false
    t.string   "membership_status",      default: "",    null: false
    t.string   "pledge_class",           default: "",    null: false
    t.string   "major",                  default: "",    null: false
    t.integer  "graduation_year",        default: 0,     null: false
    t.string   "shirt_size",             default: "",    null: false
    t.date     "birthday"
    t.boolean  "car",                    default: false, null: false
    t.boolean  "admin",                  default: false, null: false
    t.boolean  "approved",               default: false, null: false
    t.string   "standing"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
