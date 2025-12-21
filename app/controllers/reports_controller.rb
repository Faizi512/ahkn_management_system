class ReportsController < ApplicationController
  def index
    # Summary statistics for dashboard
    @total_voters = Voter.count
    # Attendance counts only include voters with execution_no
    @total_printed = Voter.where(printed: true).where("execution_no IS NOT NULL AND execution_no != ''").count
    @total_pending = Voter.where(printed: false).where("execution_no IS NOT NULL AND execution_no != ''").count
    @total_locked = Voter.where(disabled: true).count
    @total_guest_entries = Voter.where(guest_entry: true).count
    
    # Gender breakdown (odd CNIC = male, even = female)
    # Remove non-numeric characters before casting, handle NULL/empty values
    @male_count = Voter.where("cnic IS NOT NULL AND cnic != '' AND CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 != 0").count
    @female_count = Voter.where("cnic IS NOT NULL AND cnic != '' AND CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 = 0").count
    
    # Voters with execution_no (registered members)
    @male_voters_with_exec = Voter.where("cnic IS NOT NULL AND cnic != '' AND execution_no IS NOT NULL AND execution_no != '' AND CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 != 0").count
    @female_voters_with_exec = Voter.where("cnic IS NOT NULL AND cnic != '' AND execution_no IS NOT NULL AND execution_no != '' AND CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 = 0").count
    
    # Non-voters (without execution_no)
    @male_non_voters = Voter.where("cnic IS NOT NULL AND cnic != '' AND (execution_no IS NULL OR execution_no = '') AND CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 != 0").count
    @female_non_voters = Voter.where("cnic IS NOT NULL AND cnic != '' AND (execution_no IS NULL OR execution_no = '') AND CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 = 0").count
    
    # Today's statistics (only voters with execution_no)
    @today_printed = Voter.where(printed: true)
                          .where("execution_no IS NOT NULL AND execution_no != ''")
                          .where("updated_at >= ?", Date.today.beginning_of_day)
                          .count
    
    # Latest token number
    @latest_token = Voter.maximum(:token_number) || 0
  end

  def attendance
    # Get all unique Qabeela values for dropdown
    @qabeela_options = Voter.where.not(qabeela: [nil, '']).distinct.pluck(:qabeela).compact.sort
    
    # Show all printed voters in table (including guests)
    @voters = Voter.where(printed: true).order(token_number: :desc)
    
    # Filter by date if provided
    if params[:date].present?
      date = Date.parse(params[:date])
      @voters = @voters.where("DATE(updated_at) = ?", date)
    end
    
    # Filter by Qabeela if provided
    if params[:qabeela].present?
      @voters = @voters.where(qabeela: params[:qabeela])
    end
    
    # Filter by Type if provided
    if params[:type].present?
      if params[:type] == 'guest'
        @voters = @voters.where(guest_entry: true)
      elsif params[:type] == 'member'
        @voters = @voters.where("COALESCE(guest_entry, false) = false")
      end
    end
    
    # Attendance counts only include voters with execution_no
    voters_with_exec = @voters.where("execution_no IS NOT NULL AND execution_no != ''")
    @total_attendance = voters_with_exec.count
    @male_attendance = voters_with_exec.where("cnic IS NOT NULL AND cnic != '' AND CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 != 0").count
    @female_attendance = voters_with_exec.where("cnic IS NOT NULL AND cnic != '' AND CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 = 0").count
    @guest_attendance = @voters.where(guest_entry: true).count
    @member_attendance = voters_with_exec.where("COALESCE(guest_entry, false) = false").count
  end

  def gender_distribution
    @male_voters = Voter.where("cnic IS NOT NULL AND cnic != '' AND CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 != 0")
    @female_voters = Voter.where("cnic IS NOT NULL AND cnic != '' AND CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 = 0")
    
    @male_total = @male_voters.count
    @female_total = @female_voters.count
    
    # Attendance counts only include voters with execution_no
    @male_printed = @male_voters.where(printed: true).where("execution_no IS NOT NULL AND execution_no != ''").count
    @female_printed = @female_voters.where(printed: true).where("execution_no IS NOT NULL AND execution_no != ''").count
    
    # Voters with execution_no (registered members)
    @male_voters_with_exec = @male_voters.where("execution_no IS NOT NULL AND execution_no != ''").count
    @female_voters_with_exec = @female_voters.where("execution_no IS NOT NULL AND execution_no != ''").count
  end

  def qabeela_stats
    @qabeela_data = Voter.group(:qabeela)
                         .select("qabeela, 
                                  COUNT(*) as total, 
                                  SUM(CASE WHEN execution_no IS NOT NULL AND execution_no != '' THEN 1 ELSE 0 END) as total_voters,
                                  SUM(CASE WHEN printed = true AND execution_no IS NOT NULL AND execution_no != '' THEN 1 ELSE 0 END) as printed_count")
                         .order("total DESC")
  end

  def urfiat_stats
    @urfiat_data = Voter.group(:urfiat)
                        .select("urfiat, COUNT(*) as total,
                                 SUM(CASE WHEN printed = true AND execution_no IS NOT NULL AND execution_no != '' THEN 1 ELSE 0 END) as printed_count")
                        .order("total DESC")
  end

  def guest_entries
    @guests = Voter.where(guest_entry: true).order(created_at: :desc)
    
    # Filter by date if provided
    if params[:date].present?
      date = Date.parse(params[:date])
      @guests = @guests.where("DATE(created_at) = ?", date)
    end
  end

  def daily_report
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.today
    
    # Show all printed voters in table (including guests)
    @printed_today = Voter.where(printed: true)
                          .where("DATE(updated_at) = ?", @date)
                          .order(token_number: :asc)
    
    # Attendance counts only include voters with execution_no
    printed_with_exec = @printed_today.where("execution_no IS NOT NULL AND execution_no != ''")
    @total_today = printed_with_exec.count
    @male_today = printed_with_exec.where("cnic IS NOT NULL AND cnic != '' AND CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 != 0").count
    @female_today = printed_with_exec.where("cnic IS NOT NULL AND cnic != '' AND CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 = 0").count
    @guests_today = @printed_today.where(guest_entry: true).count
  end

  def welfare_status
    @welfare_data = Voter.group(:wf_upto)
                         .select("wf_upto, COUNT(*) as total,
                                  SUM(CASE WHEN printed = true AND execution_no IS NOT NULL AND execution_no != '' THEN 1 ELSE 0 END) as printed_count")
                         .order("total DESC")
  end

  def attendance_export
    # Get filtered voters (same logic as attendance action)
    voters = Voter.where(printed: true).order(token_number: :desc)
    
    # Filter by date if provided
    if params[:date].present?
      date = Date.parse(params[:date])
      voters = voters.where("DATE(updated_at) = ?", date)
    end
    
    # Filter by Qabeela if provided
    if params[:qabeela].present?
      voters = voters.where(qabeela: params[:qabeela])
    end
    
    # Filter by Type if provided
    if params[:type].present?
      if params[:type] == 'guest'
        voters = voters.where(guest_entry: true)
      elsif params[:type] == 'member'
        voters = voters.where("COALESCE(guest_entry, false) = false")
      end
    end
    
    package = Axlsx::Package.new
    workbook = package.workbook
    
    # Add styles
    header_style = workbook.styles.add_style(
      bg_color: "4472C4",
      fg_color: "FFFFFF",
      b: true,
      alignment: { horizontal: :center, vertical: :center }
    )
    
    workbook.add_worksheet(name: "Attendance Report") do |sheet|
      # Add header row
      sheet.add_row([
        "Token #",
        "Name",
        "CNIC",
        "KID",
        "Execution No",
        "Gender",
        "Type",
        "Qabeela",
        "Printed At"
      ], style: header_style)
      
      # Add data rows
      voters.each do |voter|
        gender = voter.cnic.present? && voter.cnic.to_i.even? ? "Female" : "Male"
        type = voter.guest_entry ? "Guest" : "Member"
        
        sheet.add_row([
          voter.token_number,
          voter.name,
          voter.cnic,
          voter.kid.to_i,
          voter.execution_no.presence || "-",
          gender,
          type,
          voter.qabeela,
          voter.updated_at.strftime("%d-%b-%Y %I:%M %p")
        ])
      end
      
      # Auto-adjust column widths
      sheet.column_widths 10, 30, 15, 10, 15, 10, 10, 20, 20
    end
    
    # Generate filename with filters
    filename_parts = ["attendance_report"]
    filename_parts << params[:date].gsub('-', '') if params[:date].present?
    filename_parts << params[:qabeela].gsub(' ', '_') if params[:qabeela].present?
    filename_parts << params[:type] if params[:type].present?
    filename = "#{filename_parts.join('_')}_#{Date.today.strftime('%Y%m%d')}.xlsx"
    
    send_data package.to_stream.read, 
              filename: filename,
              type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
              disposition: "attachment"
  end
end

