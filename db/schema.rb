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

ActiveRecord::Schema[7.0].define(version: 2023_12_23_201831) do
  # These are extensions that must be enabled in order to support this database
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
  end

end
