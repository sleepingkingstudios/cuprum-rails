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

ActiveRecord::Schema[7.0].define(version: 2025_06_12_054548) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "books", force: :cascade do |t|
    t.string "title", default: "", null: false
    t.string "author", default: "", null: false
    t.string "series"
    t.string "category"
    t.datetime "published_at", precision: nil
  end

  create_table "chapters", force: :cascade do |t|
    t.string "title"
    t.integer "chapter_index"
    t.bigint "book_id"
    t.index ["book_id"], name: "index_chapters_on_book_id"
  end

  create_table "covers", force: :cascade do |t|
    t.string "artist"
    t.bigint "book_id"
    t.index ["book_id"], name: "index_covers_on_book_id"
  end

  create_table "tomes", id: false, force: :cascade do |t|
    t.uuid "uuid", null: false
    t.string "title", default: "", null: false
    t.string "author", default: "", null: false
    t.string "series"
    t.string "category"
    t.datetime "published_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uuid"], name: "index_tomes_on_uuid", unique: true
  end

end
