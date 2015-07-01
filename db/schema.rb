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

ActiveRecord::Schema.define(version: 20150701023104) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "account_details", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.datetime "phone_verified_at"
    t.string   "confirmation_code"
    t.hstore   "account_data"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "account_details", ["user_id"], name: "index_account_details_on_user_id", using: :btree

  create_table "charge_wizards", force: :cascade do |t|
    t.json     "progress"
    t.boolean  "in_progress"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "charge_wizards", ["user_id"], name: "index_charge_wizards_on_user_id", using: :btree

  create_table "charges", force: :cascade do |t|
    t.text     "description"
    t.integer  "user_id"
    t.integer  "amount"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "renewal_period_in_weeks"
    t.date     "billing_day"
    t.boolean  "wizard_complete"
    t.date     "last_date_billed"
    t.integer  "merchant_id"
    t.boolean  "recurring"
    t.integer  "billed_to_date"
    t.integer  "recurring_score"
    t.integer  "transaction_request_id"
    t.integer  "linked_account_id"
    t.integer  "trym_category_id"
    t.hstore   "history"
    t.string   "plaid_name"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "charges", ["linked_account_id"], name: "index_charges_on_linked_account_id", using: :btree
  add_index "charges", ["merchant_id"], name: "index_charges_on_merchant_id", using: :btree
  add_index "charges", ["transaction_request_id"], name: "index_charges_on_transaction_request_id", using: :btree
  add_index "charges", ["trym_category_id"], name: "index_charges_on_trym_category_id", using: :btree
  add_index "charges", ["user_id"], name: "index_charges_on_user_id", using: :btree

  create_table "financial_institutions", force: :cascade do |t|
    t.string   "name"
    t.string   "plaid_type"
    t.boolean  "has_mfa"
    t.string   "mfa"
    t.string   "plaid_id"
    t.boolean  "connect"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invite_requests", force: :cascade do |t|
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "linked_accounts", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "financial_institution_id"
    t.string   "plaid_access_token"
    t.datetime "last_successful_sync"
    t.hstore   "last_api_response"
    t.text     "mfa_question"
    t.text     "mfa_type"
    t.datetime "destroyed_at"
    t.text     "status"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "linked_accounts", ["financial_institution_id"], name: "index_linked_accounts_on_financial_institution_id", using: :btree
  add_index "linked_accounts", ["user_id"], name: "index_linked_accounts_on_user_id", using: :btree

  create_table "merchants", force: :cascade do |t|
    t.string   "name"
    t.string   "type"
    t.boolean  "validated"
    t.integer  "recurring_score"
    t.integer  "trym_category_id"
    t.json     "cancellation_fields"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "merchants", ["trym_category_id"], name: "index_merchants_on_trym_category_id", using: :btree

  create_table "notes", force: :cascade do |t|
    t.integer  "noteable_id"
    t.string   "noteable_type"
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "notes", ["user_id"], name: "index_notes_on_user_id", using: :btree

  create_table "plaid_categories", force: :cascade do |t|
    t.string   "plaid_type"
    t.string   "hierarchy"
    t.string   "plaid_id"
    t.integer  "trym_category_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "plaid_categories", ["trym_category_id"], name: "index_plaid_categories_on_trym_category_id", using: :btree

  create_table "transaction_requests", force: :cascade do |t|
    t.integer  "linked_account_id"
    t.json     "data"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "transaction_requests", ["linked_account_id"], name: "index_transaction_requests_on_linked_account_id", using: :btree

  create_table "trym_categories", force: :cascade do |t|
    t.string   "name"
    t.boolean  "recurring"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "account_details", "users"
  add_foreign_key "charge_wizards", "users"
  add_foreign_key "charges", "linked_accounts"
  add_foreign_key "charges", "merchants"
  add_foreign_key "charges", "transaction_requests"
  add_foreign_key "charges", "trym_categories"
  add_foreign_key "charges", "users"
  add_foreign_key "linked_accounts", "financial_institutions"
  add_foreign_key "linked_accounts", "users"
  add_foreign_key "merchants", "trym_categories"
  add_foreign_key "notes", "users"
  add_foreign_key "plaid_categories", "trym_categories"
  add_foreign_key "transaction_requests", "linked_accounts"
end
