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

ActiveRecord::Schema.define(version: 20150216190152) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "account_details", force: true do |t|
    t.integer  "user_id"
    t.text     "first_name"
    t.text     "last_name"
    t.text     "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "phone_verified"
    t.text     "confirmation_code"
  end

  add_index "account_details", ["user_id"], name: "index_account_details_on_user_id", using: :btree

  create_table "charges", force: true do |t|
    t.text     "description"
    t.integer  "user_id"
    t.integer  "amount"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "renewal_period_in_weeks"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "billing_day"
    t.boolean  "active"
    t.date     "last_date_billed"
    t.integer  "merchant_id"
    t.boolean  "recurring"
    t.integer  "billed_to_date"
    t.integer  "recurring_score",         default: 0,     null: false
    t.integer  "transaction_request_id"
    t.integer  "linked_account_id"
    t.string   "category_id"
    t.boolean  "new_transaction",         default: false, null: false
    t.hstore   "history"
  end

  add_index "charges", ["linked_account_id"], name: "index_charges_on_linked_account_id", using: :btree
  add_index "charges", ["recurring"], name: "index_charges_on_recurring", where: "(recurring = true)", using: :btree
  add_index "charges", ["transaction_request_id"], name: "index_charges_on_transaction_request_id", using: :btree
  add_index "charges", ["user_id"], name: "index_charges_on_user_id", using: :btree

  create_table "financial_institutions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "plaid_type"
    t.boolean  "has_mfa"
    t.string   "mfa",        array: true
    t.string   "plaid_id"
    t.boolean  "connect"
  end

  create_table "invite_requests", force: true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "linked_accounts", force: true do |t|
    t.integer  "user_id",                  null: false
    t.integer  "financial_institution_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "plaid_access_token"
    t.datetime "last_successful_sync"
    t.hstore   "last_api_response"
    t.text     "mfa_question"
    t.text     "mfa_type"
    t.datetime "destroyed_at"
  end

  add_index "linked_accounts", ["financial_institution_id"], name: "index_linked_accounts_on_financial_institution_id", using: :btree
  add_index "linked_accounts", ["user_id"], name: "index_linked_accounts_on_user_id", using: :btree

  create_table "merchants", force: true do |t|
    t.text     "name"
    t.text     "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "website"
    t.boolean  "validated",          default: false, null: false
    t.text     "cancelation_fields",                              array: true
  end

  create_table "notes", force: true do |t|
    t.integer  "noteable_id"
    t.string   "noteable_type"
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["noteable_id", "noteable_type"], name: "index_notes_on_noteable_id_and_noteable_type", using: :btree
  add_index "notes", ["user_id"], name: "index_notes_on_user_id", using: :btree

  create_table "stop_orders", force: true do |t|
    t.integer  "charge_id"
    t.integer  "merchant_id"
    t.text     "status",           default: "requested"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.hstore   "cancelation_data"
  end

  add_index "stop_orders", ["charge_id"], name: "index_stop_orders_on_charge_id", using: :btree
  add_index "stop_orders", ["merchant_id"], name: "index_stop_orders_on_merchant_id", using: :btree

  create_table "transaction_requests", force: true do |t|
    t.integer "linked_account_id"
    t.json    "data"
  end

  create_table "trigrams", force: true do |t|
    t.string  "trigram",     limit: 3
    t.integer "score",       limit: 2
    t.integer "owner_id"
    t.string  "owner_type"
    t.string  "fuzzy_field"
  end

  add_index "trigrams", ["owner_id", "owner_type", "fuzzy_field", "trigram", "score"], name: "index_for_match", using: :btree
  add_index "trigrams", ["owner_id", "owner_type"], name: "index_by_owner", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "email_summary",          default: false, null: false
    t.boolean  "email_alert",            default: false, null: false
    t.boolean  "text_summary",           default: false, null: false
    t.boolean  "text_alert",             default: false, null: false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean  "admin"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
    t.string   "plaid_access_token"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
