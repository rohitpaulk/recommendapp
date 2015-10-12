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

ActiveRecord::Schema.define(version: 20151012131710) do

  create_table "android_apps", force: :cascade do |t|
    t.string   "uid"
    t.string   "display_name"
    t.string   "icon_url"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "rating"
    t.string   "description"
    t.integer  "recommendations_count"
  end

  add_index "android_apps", ["uid"], name: "index_android_apps_on_uid", unique: true

  create_table "elsewheres", force: :cascade do |t|
    t.string  "provider"
    t.string  "uid"
    t.string  "access_token"
    t.integer "user_id"
  end

  add_index "elsewheres", ["uid", "provider"], name: "index_elsewheres_on_uid_and_provider", unique: true

  create_table "movies", force: :cascade do |t|
    t.string   "title"
    t.string   "year"
    t.string   "plot"
    t.string   "imdb_rating"
    t.string   "imdb_id"
    t.string   "poster_url"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "recommendations_count"
  end

  add_index "movies", ["imdb_id"], name: "index_movies_on_imdb_id", unique: true

  create_table "recommendations", force: :cascade do |t|
    t.integer  "recommender_id"
    t.integer  "recommendee_id"
    t.integer  "item_id"
    t.string   "item_type"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recommendations", ["item_id", "recommendee_id", "recommender_id", "item_type"], name: "index_for_unique_recommendation", unique: true

  create_table "requests", force: :cascade do |t|
    t.integer  "requestee_id"
    t.integer  "requester_id"
    t.string   "item_type"
    t.string   "status"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "response_id"
  end

  add_index "requests", ["item_type", "requestee_id", "requester_id"], name: "index_requests_on_item_type_and_requestee_id_and_requester_id", unique: true, where: "status IN (\"pending\",\"sent\")"
  add_index "requests", ["response_id"], name: "index_requests_on_response_id", unique: true

  create_table "user_followers", force: :cascade do |t|
    t.integer  "follower_id"
    t.integer  "following_id"
    t.string   "derived_from"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_followers", ["follower_id", "following_id"], name: "index_user_followers_on_follower_id_and_following_id", unique: true

  create_table "user_items", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "item_id"
    t.string   "item_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "like"
  end

  add_index "user_items", ["user_id", "item_id", "item_type"], name: "index_user_items_on_user_id_and_item_id_and_item_type", unique: true

  create_table "users", force: :cascade do |t|
    t.string   "api_access_token"
    t.string   "name"
    t.string   "avatar_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "push_id"
    t.boolean  "logged_in",        default: true
  end

  add_index "users", ["api_access_token"], name: "index_users_on_api_access_token", unique: true

end
