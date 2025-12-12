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
    # Show all printed voters in table (including guests)
    @voters = Voter.where(printed: true).order(token_number: :desc)
    
    # Filter by date if provided
    if params[:date].present?
      date = Date.parse(params[:date])
      @voters = @voters.where("DATE(updated_at) = ?", date)
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
                         .select("qabeela, COUNT(*) as total, 
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
end

