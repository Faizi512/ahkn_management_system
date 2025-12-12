require 'roo'

class DataLoaderService
  BATCH_SIZE = 1000  # Insert 1000 records at a time

  def initialize(file)
    @file = file
  end

  def load_voters
    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1)
    
    records = []
    current_time = Time.now

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      
      # Map Excel column names to database column names
      mapped_row = {
        cnic: clean_cnic(row["CNIC"]),
        kid: row["KID"],
        name: row["NAME"],
        father_name: row["FATHER NAME"],
        age: row["AGE"],
        date_of_birth: row["DOB"],
        voter_status: "Voter",
        created_at: current_time,
        updated_at: current_time,
        disabled: false,
        printed: false,
        voter_no: row["VOTER NO"],
        akhn: row["AKHN"],
        verification: row["VERIFICATION"],
        execution_no: row["EXECUTION NO"],
        f_cnic: clean_cnic(row["F. CNIC"]),
        spouse_name: row["SPOUSE NAME"],
        sp_cnic: clean_cnic(row["SP. CNIC"]),
        qaber: row["QABER"],
        address: row["ADDRESS"],
        city: row["CITY"],
        cell_no: row["CELL #"],
        mobile: row["MOBILE NO"],
        cnic_chk: clean_cnic(row["CNIC CHK"]),
        qabeela: row["QABEELA"],
        urfiat: row["URFIAT"],
        wf_upto: row["W/F UPTO"],
        family_no: row["FAMILY NO"],
        dob: row["DOB"],
        kid_chk: row["KID CHK"]
      }
      
      records << mapped_row
      
      # Bulk insert when batch size is reached
      if records.size >= BATCH_SIZE
        Voter.insert_all(records)
        puts "Inserted #{i - 1} records..."
        records = []
      end
    end
    
    # Insert remaining records
    Voter.insert_all(records) if records.any?
    puts "Import completed! Total: #{spreadsheet.last_row - 1} records"
  end

  private

  def clean_cnic(value)
    return nil if value.nil?
    value.to_s.gsub(/[-\s]/, '')  # Remove dashes and spaces
  end

  def open_spreadsheet
    case File.extname(@file.original_filename)
    when '.xls' then Roo::Excel.new(@file.path)
    when '.xlsx' then Roo::Excelx.new(@file.path)
    else raise "Unknown file type: #{@file.original_filename}"
    end
  end
end
