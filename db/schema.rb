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

ActiveRecord::Schema[7.0].define(version: 2025_12_12_091528) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "voters", force: :cascade do |t|
    t.string "cnic"
    t.string "kid"
    t.string "name"
    t.string "father_name"
    t.integer "age"
    t.date "date_of_birth"
    t.string "voter_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "disabled"
    t.boolean "printed"
    t.string "voter_no"
    t.string "akhn"
    t.string "verification"
    t.string "execution_no"
    t.string "f_cnic"
    t.string "spouse_name"
    t.string "sp_cnic"
    t.string "qaber"
    t.string "address"
    t.string "city"
    t.string "cell_no"
    t.string "mobile"
    t.string "cnic_chk"
    t.string "qabeela"
    t.string "urfiat"
    t.string "wf_upto"
    t.string "family_no"
    t.string "dob"
    t.string "kid_chk"
    t.integer "token_number"
    t.boolean "guest_entry"
    t.index ["cnic"], name: "index_voters_on_cnic"
    t.index ["cnic_chk"], name: "index_voters_on_cnic_chk"
    t.index ["disabled"], name: "index_voters_on_disabled"
    t.index ["family_no"], name: "index_voters_on_family_no"
    t.index ["father_name"], name: "index_voters_on_father_name", opclass: :gin_trgm_ops, using: :gin
    t.index ["guest_entry"], name: "index_voters_on_guest_entry"
    t.index ["kid"], name: "index_voters_on_kid"
    t.index ["kid_chk"], name: "index_voters_on_kid_chk"
    t.index ["name"], name: "index_voters_on_name", opclass: :gin_trgm_ops, using: :gin
    t.index ["printed", "updated_at"], name: "index_voters_on_printed_and_updated_at"
    t.index ["printed"], name: "index_voters_on_printed"
    t.index ["token_number"], name: "index_voters_on_token_number"
    t.index ["voter_no"], name: "index_voters_on_voter_no"
  end

end
