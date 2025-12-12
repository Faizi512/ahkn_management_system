class ReportsController < ApplicationController
  def index
    # Summary statistics for dashboard
    @total_voters = Voter.count
    @total_printed = Voter.where(printed: true).count
    @total_pending = Voter.where(printed: false).count
    @total_locked = Voter.where(disabled: true).count
    @total_guest_entries = Voter.where(guest_entry: true).count
    
    # Gender breakdown (odd CNIC = male, even = female)
    # Remove non-numeric characters before casting, handle NULL/empty values
    @male_count = Voter.where("cnic IS NOT NULL AND cnic != '' AND CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 != 0").count
    @female_count = Voter.where("cnic IS NOT NULL AND cnic != '' AND CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 = 0").count
    
    # Today's statistics
    @today_printed = Voter.where(printed: true)
                          .where("updated_at >= ?", Date.today.beginning_of_day)
                          .count
    
    # Latest token number
    @latest_token = Voter.maximum(:token_number) || 0
  end

  def attendance
    @voters = Voter.where(printed: true).order(token_number: :desc)
    
    # Filter by date if provided
    if params[:date].present?
      date = Date.parse(params[:date])
      @voters = @voters.where("DATE(updated_at) = ?", date)
    end
    
    @total_attendance = @voters.count
    @male_attendance = @voters.where("cnic IS NOT NULL AND cnic != '' AND CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 != 0").count
    @female_attendance = @voters.where("cnic IS NOT NULL AND cnic != '' AND CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 = 0").count
    @guest_attendance = @voters.where(guest_entry: true).count
    @member_attendance = @voters.where(guest_entry: false).count
  end

  def gender_distribution
    @male_voters = Voter.where("cnic IS NOT NULL AND cnic != '' AND CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 != 0")
    @female_voters = Voter.where("cnic IS NOT NULL AND cnic != '' AND CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 = 0")
    
    @male_total = @male_voters.count
    @female_total = @female_voters.count
    
    @male_printed = @male_voters.where(printed: true).count
    @female_printed = @female_voters.where(printed: true).count
  end

  def qabeela_stats
    @qabeela_data = Voter.group(:qabeela)
                         .select("qabeela, COUNT(*) as total, 
                                  SUM(CASE WHEN printed = true THEN 1 ELSE 0 END) as printed_count")
                         .order("total DESC")
  end

  def urfiat_stats
    @urfiat_data = Voter.group(:urfiat)
                        .select("urfiat, COUNT(*) as total,
                                 SUM(CASE WHEN printed = true THEN 1 ELSE 0 END) as printed_count")
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
    
    @printed_today = Voter.where(printed: true)
                          .where("DATE(updated_at) = ?", @date)
                          .order(token_number: :asc)
    
    @total_today = @printed_today.count
    @male_today = @printed_today.where("cnic IS NOT NULL AND cnic != '' AND CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 != 0").count
    @female_today = @printed_today.where("cnic IS NOT NULL AND cnic != '' AND CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 = 0").count
    @guests_today = @printed_today.where(guest_entry: true).count
  end

  def welfare_status
    @welfare_data = Voter.group(:wf_upto)
                         .select("wf_upto, COUNT(*) as total,
                                  SUM(CASE WHEN printed = true THEN 1 ELSE 0 END) as printed_count")
                         .order("total DESC")
  end
end

