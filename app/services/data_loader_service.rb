require 'roo'

class DataLoaderService
  def initialize(file)
    @file = file
  end

  def load_voters
    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1)

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      # byebug
      # Map Excel column names to database column names
      mapped_row = {
        "cnic" => row["CNIC"]&.split("-")&.join,
        "kid" => row["KID"],
        "name" => row["NAME"],
        "father_name" => row["FATHER NAME"],
        "age" => row["AGE"],
        "date_of_birth" => row["DOB"],
        "voter_status" => "Voter",
        "created_at" => Time.now,
        "updated_at" => Time.now,
        "disabled" => false,
        "printed" => false,
        "voter_no" => row["VOTER NO"],
        "akhn" => row["AKHN"],
        "verification" => row["VERIFICATION"],
        "execution_no" => row["EXECUTION NO"],
        "f_cnic" => row["F. CNIC"]&.split("-")&.join,
        "spouse_name" => row["SPOUSE NAME"],
        "sp_cnic" => row["SP. CNIC"]&.split("-")&.join,
        "qaber" => row["QABER"],
        "address" => row["ADDRESS"],
        "city" => row["CITY"],
        "cell_no" => row["CELL #"],
        "mobile" => row["MOBILE NO"],
        "cnic_chk" => row["CNIC CHK"]&.split("-")&.join,
        "qabeela" => row["QABEELA"],
        "urfiat" => row["URFIAT"],
        "wf_upto" => row["W/F UPTO"],
        "family_no" => row["FAMULY NO"],
        "dob" => row["DOB"],
        "kid_chk" => row["KID CHK"]
      }
      # byebug
      # mapped_row = {
      #   "cnic" => row["CNIC"]&.split("-")&.join,
      #   "kid" => row["CndID"],
      #   "name" => row["Name"],
      #   "father_name" => row["FName"],
      #   "age" => row["AGE"],
      #   "date_of_birth" => row["DOB"],
      #   "voter_status" => "Voter",
      #   "created_at" => Time.now,
      #   "updated_at" => Time.now,
      #   "disabled" => false,
      #   "printed" => false,
      #   "voter_no" => row["VOTER NO"],
      #   "akhn" => row["AKHN"],
      #   "verification" => row["VERIFICATION"],
      #   "execution_no" => row["EXECUTION NO"],
      #   "f_cnic" => row["F. CNIC"]&.split("-")&.join,
      #   "spouse_name" => row["SPOUSE NAME"],
      #   "sp_cnic" => row["SP. CNIC"]&.split("-")&.join,
      #   "qaber" => row["QABER"],
      #   "address" => row["ADDRESS"],
      #   "city" => row["CITY"],
      #   "cell_no" => row["MobileNo"],
      #   "mobile" => row["MobileNo"],
      #   "cnic_chk" => row["CNIC CHK"]&.split("-")&.join,
      #   "qabeela" => row["QabeelaName"],
      #   "urfiat" => row["UrfiatName"],
      #   "wf_upto" => row["FWelfareFundNo"],
      #   "family_no" => row["FAMILY NO"],
      #   "dob" => row["DOB"],
      #   "kid_chk" => row["CndID"]
      # }
      puts mapped_row
      Voter.create!(mapped_row)
    end
  end

  private

  def open_spreadsheet
    case File.extname(@file.original_filename)
    when '.xls' then Roo::Excel.new(@file.path)
    when '.xlsx' then Roo::Excelx.new(@file.path)
    else raise "Unknown file type: #{@file.original_filename}"
    end
  end
end
