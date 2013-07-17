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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130716161939) do

  create_table "collection_items_assocs", :force => true do |t|
    t.string   "item_id"
    t.string   "collection_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "collections", :force => true do |t|
    t.string   "name"
    t.string   "season"
    t.string   "year"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "item_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "items", :force => true do |t|
    t.string   "reference"
    t.string   "name"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "item_type_id"
    t.string   "tibbr_id"
    t.string   "tibbr_key"
  end

  create_table "pictures", :force => true do |t|
    t.string   "image"
    t.string   "thumb"
    t.string   "big"
    t.string   "title"
    t.string   "description"
    t.string   "link"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "item_id"
  end

  create_table "setups", :force => true do |t|
    t.string   "app_id"
    t.string   "client_secret"
    t.string   "server_url"
    t.string   "system_admin_id"
    t.string   "tenant_name"
    t.string   "access_token"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "stores", :force => true do |t|
    t.string   "name"
    t.string   "street_number"
    t.string   "street"
    t.string   "zipcode"
    t.string   "city"
    t.string   "country"
    t.string   "longitude"
    t.string   "latitude"
    t.string   "manager"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "tibbr_id"
    t.string   "tibbr_key"
  end

end
