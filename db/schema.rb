# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_01_094545) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"
  enable_extension "postgis"

  create_table "categories", force: :cascade do |t|
    t.string "code", null: false
    t.jsonb "code_translations", default: {}
    t.datetime "created_at", null: false
    t.string "hex_color"
    t.string "icon"
    t.bigint "parent_id"
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_categories_on_code", unique: true
    t.index ["parent_id"], name: "index_categories_on_parent_id"
  end

  create_table "marker_submissions", force: :cascade do |t|
    t.string "address"
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.string "description_en"
    t.decimal "latitude", precision: 10, scale: 6, null: false
    t.decimal "longitude", precision: 10, scale: 6, null: false
    t.string "name", null: false
    t.string "name_en"
    t.string "new_child_name"
    t.string "new_parent_name"
    t.bigint "parent_category_id"
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_marker_submissions_on_category_id"
    t.index ["latitude", "longitude"], name: "index_marker_submissions_on_latitude_and_longitude"
    t.index ["parent_category_id"], name: "index_marker_submissions_on_parent_category_id"
  end

  create_table "markers", force: :cascade do |t|
    t.string "address"
    t.geography "coordinates", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.datetime "created_at", null: false
    t.text "description"
    t.jsonb "description_translations", default: {}
    t.float "latitude", null: false
    t.float "longitude", null: false
    t.string "name"
    t.jsonb "name_translations", default: {}
    t.datetime "updated_at", null: false
    t.index ["coordinates"], name: "index_markers_on_coordinates", using: :gist
  end

  create_table "markers_categories", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.bigint "marker_id", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_markers_categories_on_category_id"
    t.index ["marker_id", "category_id"], name: "index_markers_categories_on_marker_id_and_category_id", unique: true
    t.index ["marker_id"], name: "index_markers_categories_on_marker_id"
  end

  create_table "places", force: :cascade do |t|
    t.geography "coordinates", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.jsonb "name_translations", default: {}
    t.bigint "parent_id"
    t.datetime "updated_at", null: false
    t.index ["coordinates"], name: "index_places_on_coordinates", using: :gist
    t.index ["name"], name: "index_places_on_name", opclass: :gin_trgm_ops, using: :gin
    t.index ["parent_id"], name: "index_places_on_parent_id"
  end

  create_table "proposals", force: :cascade do |t|
    t.string "action", null: false
    t.float "confidence"
    t.datetime "created_at", null: false
    t.bigint "marker_submission_id", null: false
    t.jsonb "proposed_data", default: {}, null: false
    t.text "reviewer_notes"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["marker_submission_id"], name: "index_proposals_on_marker_submission_id"
    t.index ["status"], name: "index_proposals_on_status"
  end

  create_table "suggestions", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "marker_submissions", "categories", column: "parent_category_id", name: "marker_submissions_parent_category_id_fkey"
  add_foreign_key "marker_submissions", "categories", name: "marker_submissions_category_id_fkey"
  add_foreign_key "markers_categories", "categories"
  add_foreign_key "markers_categories", "markers"
  add_foreign_key "places", "places", column: "parent_id"
end
