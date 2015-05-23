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

ActiveRecord::Schema.define(version: 20150511230243) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookings", force: true do |t|
    t.integer  "space_id"
    t.integer  "state"
    t.datetime "from"
    t.datetime "to"
    t.integer  "b_type"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "price"
    t.datetime "owner_last_seen"
    t.datetime "venue_last_seen"
    t.datetime "approved_at"
    t.integer  "payment_id"
    t.string   "payment_type"
    t.boolean  "owner_delete",       default: false
    t.boolean  "venue_owner_delete", default: false
    t.integer  "fee"
    t.integer  "deposit"
    t.boolean  "hold_deposit",       default: false
  end

  add_index "bookings", ["owner_id", "owner_type"], name: "index_bookings_on_owner_id_and_owner_type", using: :btree
  add_index "bookings", ["payment_id", "payment_type"], name: "index_bookings_on_payment_id_and_payment_type", using: :btree
  add_index "bookings", ["space_id"], name: "index_bookings_on_space_id", using: :btree

  create_table "braintree_collection_accounts", force: true do |t|
    t.boolean  "active",                       default: false
    t.string   "status"
    t.text     "error_message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "merchant_account_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone"
    t.date     "date_of_birth"
    t.string   "ssn_last_4"
    t.string   "individual_street_address"
    t.string   "individual_locality"
    t.string   "individual_region"
    t.string   "individual_postal_code"
    t.string   "legal_name"
    t.string   "dba_name"
    t.string   "tax_id"
    t.string   "business_street_address"
    t.string   "business_locality"
    t.string   "business_region"
    t.string   "business_postal_code"
    t.string   "descriptor"
    t.string   "account_number_last_4"
    t.string   "routing_number"
    t.boolean  "braintree_persisted"
    t.boolean  "expecting_braintree_response"
  end

  create_table "braintree_payment_accounts", force: true do |t|
    t.integer  "buyer_id"
    t.string   "buyer_type"
    t.string   "braintree_customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "braintree_payment_accounts", ["buyer_id", "buyer_type"], name: "index_braintree_payment_accounts_on_buyer_id_and_buyer_type", using: :btree

  create_table "braintree_payments", force: true do |t|
    t.string   "transaction_status"
    t.string   "escrow_status"
    t.string   "transaction_id"
    t.text     "error_message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "payment_nonce_token"
    t.datetime "payment_nonce_expire"
    t.string   "card_type"
    t.string   "card_last_4"
    t.string   "card_expiration_date"
  end

  create_table "client_reviews", force: true do |t|
    t.text     "message"
    t.integer  "stars"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "booking_id"
  end

  add_index "client_reviews", ["booking_id"], name: "index_client_reviews_on_booking_id", using: :btree

  create_table "mangopay_collection_accounts", force: true do |t|
    t.boolean  "active",                      default: false
    t.string   "status"
    t.text     "error_message"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "nationality"
    t.string   "country_of_residence"
    t.date     "date_of_birth"
    t.string   "address"
    t.string   "legal_person_type"
    t.string   "business_name"
    t.string   "business_email"
    t.string   "bank_type"
    t.string   "iban_last_4"
    t.string   "bic"
    t.string   "account_number_last_4"
    t.string   "sort_code"
    t.string   "bank_name"
    t.string   "institution_number"
    t.string   "branch_code"
    t.string   "bank_country"
    t.string   "mangopay_user_id"
    t.string   "wallet_id"
    t.string   "bank_account_id"
    t.boolean  "mangopay_persisted"
    t.boolean  "expecting_mangopay_response"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mangopay_credit_cards", force: true do |t|
    t.string   "credit_card_id"
    t.string   "last_4"
    t.string   "expiration"
    t.string   "card_type"
    t.integer  "mangopay_payment_account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status"
    t.string   "currency"
    t.string   "card_registration_url"
    t.string   "pre_registration_data"
    t.string   "registration_access_key"
    t.string   "registration_id"
    t.datetime "registration_expiration_date"
    t.text     "error_message"
  end

  add_index "mangopay_credit_cards", ["mangopay_payment_account_id"], name: "index_mangopay_credit_cards_on_mangopay_payment_account_id", using: :btree

  create_table "mangopay_payment_accounts", force: true do |t|
    t.integer  "buyer_id"
    t.string   "buyer_type"
    t.string   "mangopay_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status"
    t.text     "error_message"
    t.string   "wallet_id"
  end

  add_index "mangopay_payment_accounts", ["buyer_id", "buyer_type"], name: "index_mangopay_payment_accounts_on_buyer_id_and_buyer_type", using: :btree

  create_table "mangopay_payments", force: true do |t|
    t.string   "transaction_status"
    t.string   "transaction_id"
    t.text     "error_message"
    t.string   "card_type"
    t.string   "card_last_4"
    t.string   "card_expiration_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "notification_date_int"
    t.string   "redirect_url"
    t.integer  "user_paying_id"
    t.integer  "price_amount_in_wallet"
    t.integer  "deposit_amount_in_wallet"
  end

  add_index "mangopay_payments", ["transaction_id"], name: "index_mangopay_payments_on_transaction_id", unique: true, using: :btree
  add_index "mangopay_payments", ["user_paying_id"], name: "index_mangopay_payments_on_user_paying_id", using: :btree

  create_table "mangopay_payouts", force: true do |t|
    t.integer  "p_types"
    t.string   "transaction_id"
    t.string   "transference_id"
    t.string   "transaction_status"
    t.text     "error_message"
    t.integer  "mangopay_payment_id"
    t.integer  "notification_date_int"
    t.integer  "amount"
    t.integer  "fee"
    t.integer  "retries"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mangopay_payouts", ["mangopay_payment_id"], name: "index_mangopay_payouts_on_mangopay_payment_id", using: :btree
  add_index "mangopay_payouts", ["transaction_id"], name: "index_mangopay_payouts_on_transaction_id", unique: true, using: :btree
  add_index "mangopay_payouts", ["transference_id"], name: "index_mangopay_payouts_on_transference_id", unique: true, using: :btree

  create_table "messages", force: true do |t|
    t.integer  "booking_id"
    t.integer  "user_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "m_type"
    t.integer  "represented_id"
    t.string   "represented_type"
  end

  add_index "messages", ["booking_id"], name: "index_messages_on_booking_id", using: :btree
  add_index "messages", ["represented_id", "represented_type"], name: "index_messages_on_represented_id_and_represented_type", using: :btree
  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "organization_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
  end

  add_index "organization_users", ["user_id"], name: "index_organization_users_on_user_id", using: :btree

  create_table "organizations", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "rating"
    t.integer  "quantity_reviews"
    t.integer  "reviews_sum"
    t.string   "logo"
  end

  add_index "organizations", ["email"], name: "index_organizations_on_email", unique: true, using: :btree

  create_table "spaces", force: true do |t|
    t.integer  "s_type"
    t.string   "name"
    t.integer  "capacity"
    t.integer  "quantity"
    t.text     "description"
    t.integer  "venue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hour_price"
    t.integer  "day_price"
    t.integer  "week_price"
    t.integer  "month_price"
    t.integer  "deposit"
  end

  add_index "spaces", ["venue_id"], name: "index_spaces_on_venue_id", using: :btree

  create_table "time_zones", force: true do |t|
    t.string   "zone_identifier"
    t.integer  "seconds_utc_difference"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "time_zones", ["zone_identifier"], name: "index_time_zones_on_zone_identifier", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone"
    t.string   "language"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "rating"
    t.integer  "quantity_reviews"
    t.integer  "reviews_sum"
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "provider"
    t.string   "uid"
    t.string   "avatar"
    t.datetime "date_of_birth"
    t.string   "gender"
    t.text     "languages_spoken",       default: [],              array: true
    t.string   "profession"
    t.string   "company_name"
    t.text     "interests"
    t.string   "location"
    t.string   "emergency_name"
    t.string   "emergency_email"
    t.string   "emergency_phone"
    t.string   "emergency_relationship"
    t.string   "nationality"
    t.string   "country_of_residence"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_favorites", force: true do |t|
    t.integer  "user_id"
    t.integer  "space_id"
    t.date     "since"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users_favorites", ["space_id"], name: "index_users_favorites_on_space_id", using: :btree
  add_index "users_favorites", ["user_id"], name: "index_users_favorites_on_user_id", using: :btree

  create_table "venue_hours", force: true do |t|
    t.integer  "weekday"
    t.integer  "from"
    t.integer  "to"
    t.integer  "venue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "venue_hours", ["venue_id"], name: "index_venue_hours_on_venue_id", using: :btree

  create_table "venue_photos", force: true do |t|
    t.integer  "venue_id"
    t.string   "photo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "space_id"
  end

  add_index "venue_photos", ["space_id"], name: "index_venue_photos_on_space_id", using: :btree
  add_index "venue_photos", ["venue_id"], name: "index_venue_photos_on_venue_id", using: :btree

  create_table "venue_reviews", force: true do |t|
    t.text     "message"
    t.integer  "stars"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "booking_id"
  end

  add_index "venue_reviews", ["booking_id"], name: "index_venue_reviews_on_booking_id", using: :btree

  create_table "venues", force: true do |t|
    t.string   "town"
    t.string   "street"
    t.string   "postal_code"
    t.string   "phone"
    t.string   "email"
    t.string   "website"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.string   "name"
    t.text     "description"
    t.string   "currency"
    t.string   "logo"
    t.integer  "v_type"
    t.float    "space"
    t.integer  "space_unit"
    t.integer  "floors"
    t.integer  "rooms"
    t.integer  "desks"
    t.float    "vat_tax_rate"
    t.text     "amenities",               default: [], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "rating"
    t.integer  "quantity_reviews"
    t.integer  "reviews_sum"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.text     "professions",             default: [], array: true
    t.integer  "collection_account_id"
    t.string   "collection_account_type"
    t.integer  "status"
    t.string   "country_code"
    t.text     "office_rules"
    t.integer  "time_zone_id"
  end

  add_index "venues", ["collection_account_id", "collection_account_type"], name: "index_venues_on_polymorphic_collection_account", unique: true, using: :btree
  add_index "venues", ["owner_id", "owner_type"], name: "index_venues_on_owner_id_and_owner_type", using: :btree
  add_index "venues", ["time_zone_id"], name: "index_venues_on_time_zone_id", using: :btree

end
