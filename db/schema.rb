# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_03_17_002312) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gin"
  enable_extension "plpgsql"

  create_table "albums", force: :cascade do |t|
    t.integer "artist_id"
    t.string "album_title"
    t.integer "year"
    t.string "condition"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["album_title"], name: "index_albums_on_album_title", using: :gin
  end

  create_table "artists", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "words", force: :cascade do |t|
    t.string "word"
    t.integer "count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["word"], name: "index_words_on_word"
  end

end
