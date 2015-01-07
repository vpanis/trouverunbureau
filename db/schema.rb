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

ActiveRecord::Schema.define(version: 20150106230051) do

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
  end

  add_index "bookings", ["owner_id", "owner_type"], name: "index_bookings_on_owner_id_and_owner_type", using: :btree
  add_index "bookings", ["space_id"], name: "index_bookings_on_space_id", using: :btree

  create_table "client_reviews", force: true do |t|
    t.integer  "from_user_id"
    t.text     "message"
    t.integer  "stars"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_id"
    t.string   "client_type"
  end

  add_index "client_reviews", ["client_id", "client_type"], name: "index_client_reviews_on_client_id_and_client_type", using: :btree
  add_index "client_reviews", ["from_user_id"], name: "index_client_reviews_on_from_user_id", using: :btree

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
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

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
    t.time     "from"
    t.time     "to"
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
    t.integer  "venue_id"
    t.integer  "from_user_id"
    t.text     "message"
    t.integer  "stars"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "venue_reviews", ["from_user_id"], name: "index_venue_reviews_on_from_user_id", using: :btree
  add_index "venue_reviews", ["venue_id"], name: "index_venue_reviews_on_venue_id", using: :btree

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
  end

  add_index "venues", ["owner_id", "owner_type"], name: "index_venues_on_owner_id_and_owner_type", using: :btree

end
