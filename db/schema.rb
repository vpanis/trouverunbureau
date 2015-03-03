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

ActiveRecord::Schema.define(version: 20150303194416) do

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
    t.float    "price"
    t.datetime "owner_last_seen"
    t.datetime "venue_last_seen"
    t.datetime "approved_at"
  end

  add_index "bookings", ["owner_id", "owner_type"], name: "index_bookings_on_owner_id_and_owner_type", using: :btree
  add_index "bookings", ["space_id"], name: "index_bookings_on_space_id", using: :btree

  create_table "client_reviews", force: true do |t|
    t.text     "message"
    t.integer  "stars"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "booking_id"
  end

  add_index "client_reviews", ["booking_id"], name: "index_client_reviews_on_booking_id", using: :btree

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
    t.float    "hour_price"
    t.float    "day_price"
    t.float    "week_price"
    t.float    "month_price"
  end

  add_index "spaces", ["venue_id"], name: "index_spaces_on_venue_id", using: :btree

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
    t.text     "amenities",        default: [], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "rating"
    t.integer  "quantity_reviews"
    t.integer  "reviews_sum"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.text     "professions",      default: [], array: true
    t.string   "country"
  end

  add_index "venues", ["owner_id", "owner_type"], name: "index_venues_on_owner_id_and_owner_type", using: :btree

end
