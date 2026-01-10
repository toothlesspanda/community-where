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

ActiveRecord::Schema[8.0].define(version: 2026_01_05_200935) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "postgis"

  create_table "categories", force: :cascade do |t|
    t.string "code", null: false
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_categories_on_code", unique: true
    t.index ["parent_id"], name: "index_categories_on_parent_id"
  end

  create_table "markers", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.float "longitude", null: false
    t.float "latitude", null: false
    t.geography "coordinates", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "markers_categories", force: :cascade do |t|
    t.bigint "marker_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_markers_categories_on_category_id"
    t.index ["marker_id", "category_id"], name: "index_markers_categories_on_marker_id_and_category_id", unique: true
    t.index ["marker_id"], name: "index_markers_categories_on_marker_id"
  end

  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "markers_categories", "categories"
  add_foreign_key "markers_categories", "markers"
end
