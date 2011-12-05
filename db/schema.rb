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

ActiveRecord::Schema.define(:version => 20111205213942) do

  create_table "documents", :force => true do |t|
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source"
  end

  create_table "i_match_signatures", :force => true do |t|
    t.string   "token"
    t.integer  "document_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mega_shingle_signatures", :force => true do |t|
    t.string   "token"
    t.integer  "document_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mega_shingle_signatures", ["document_id"], :name => "index_mega_shingle_signatures_on_document_id"

  create_table "min_hash_signatures", :force => true do |t|
    t.string   "token"
    t.integer  "document_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "min_hash_signatures", ["document_id"], :name => "index_min_hash_signatures_on_document_id"

  create_table "shingle_signatures", :force => true do |t|
    t.string  "token"
    t.integer "position_start"
    t.integer "position_end"
    t.integer "document_id"
  end

  add_index "shingle_signatures", ["document_id"], :name => "index_shingle_signatures_on_document_id"
  add_index "shingle_signatures", ["token"], :name => "index_shingle_signatures_on_token", :unique => true

  create_table "super_shingle_signatures", :force => true do |t|
    t.string   "token"
    t.integer  "document_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "super_shingle_signatures", ["document_id"], :name => "index_super_shingle_signatures_on_document_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "words", :force => true do |t|
    t.string  "term"
    t.integer "number_documents_found"
    t.float   "idf"
  end

  add_index "words", ["idf"], :name => "index_words_on_idf"
  add_index "words", ["term"], :name => "index_words_on_term"

end
