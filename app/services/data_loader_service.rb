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
      Voter.create!(row)
    end
  end

  private

  def open_spreadsheet
    case File.extname(@file.original_filename)
    when '.xls' then Roo::Excel.new(@file.path, nil, :ignore)
    when '.xlsx' then Roo::Excelx.new(@file.path, nil, :ignore)
    else raise "Unknown file type: #{@file.original_filename}"
    end
  end
end