require 'tzinfo'
class VoterController < ApplicationController
  before_action :set_voter, only: [:show, :edit, :update, :destroy]
  

  def index
    @voters = if params[:gender_filter].present? && params[:gender_filter] != "All"
      params[:gender_filter] == "Male" ? Voter.male : Voter.female
    else
      Voter.all
    end
  end

  def show
    # Your show action logic here
  end

  def new
    @voter = Voter.new
  end

  def create
    @voter = nil
    if !params[:guest_entry].eql?("true")
      @voter = Voter.new(voter_params)
    else
      # Clean CNIC - remove dashes and spaces
      clean_cnic = params[:cnic].to_s.gsub(/[-\s]/, '')
      
      if !Voter.where(cnic: clean_cnic).present?
        @voter = Voter.new(name: params[:name], qabeela: params[:qabeela], urfiat: params[:urfiat], cell_no: params[:phone], execution_no: params[:execution_no], cnic: clean_cnic, user_code: params[:user_code], guest_entry: params[:guest_entry])
        
        if @voter.valid?
          @voter.update!(token_number: @voter.next_token_number)
          if @voter.save
            redirect_to "/voter/search?query=#{@voter.cnic}&commit=Search", notice: 'Guest entry created successfully.'
          else
            # Pass voter to home#index view
            @voter_for_form = @voter
            render 'home/index', status: :unprocessable_entity
          end
        else
          # Pass voter to home#index view
          @voter_for_form = @voter
          render 'home/index', status: :unprocessable_entity
        end
      else
        redirect_to "/voter/search?query=#{clean_cnic}&commit=Search"
      end
      return
    end

    if !@voter.blank? && @voter.save
      if !params[:guest_entry].eql?("true")
        redirect_to @voter, notice: 'Voter was successfully created.'
      else
        redirect_to "/voter/search?query=#{@voter.cnic}&commit=Search"
      end
    else
      render :new if !@voter.blank?
    end
  end

  def edit
    # Your edit action logic here
  end

  def update
    if @voter.update(voter_params)
      redirect_to @voter, notice: 'Voter was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @voter.destroy
    redirect_to voters_url, notice: 'Voter was successfully destroyed.'
  end

  def search
    query = params[:query].to_s.strip
    
    # Clean the query - remove dashes and extra spaces
    clean_query = query.gsub(/[-\s]+/, '')
    
    # For CNIC-like queries (all numbers, 13 digits), use exact match for speed
    if clean_query.match?(/^\d{13}$/)
      @voters = Voter.where("REPLACE(cnic, '-', '') = ? OR REPLACE(cnic, ' ', '') = ?", clean_query, clean_query)
    elsif clean_query.match?(/^\d+$/)
      # Numeric query - search in CNIC, KID, family_no, etc.
      @voters = Voter.where(
        "cnic LIKE :q OR kid LIKE :q OR kid_chk LIKE :q OR family_no LIKE :q OR voter_no LIKE :q",
        q: "%#{clean_query}%"
      )
    else
      # Text query - use full-text search
      @voters = Voter.search(query)
    end
    
    # Limit results for performance
    @voters = @voters.limit(100)
    render :show
  end

  def print
    puts "Print"
    tz = TZInfo::Timezone.get('Asia/Karachi')
    @local_time = tz.to_local(Time.now.utc)
    @voter = Voter.find(params[:id])
    
    # Combine all updates into a single query
    updates = { printed: true, disabled: true }
    updates[:token_number] = @voter.next_token_number if @voter.printed == false
    @voter.update(updates)
    
    respond_to do |format|
      format.html { render layout: 'layouts/printable' }
    end
  end

  def special_print
    puts "Special Print"
    tz = TZInfo::Timezone.get('Asia/Karachi')
    @local_time = tz.to_local(Time.now.utc)
    @voter = Voter.find(params[:id])
    
    # Combine all updates into a single query
    @voter.update(printed: true, disabled: true)
    
    respond_to do |format|
      format.html { render layout: 'layouts/printable' }
    end
  end

  def lock
    puts "Lock"
    @voter = Voter.find(params[:id])
    @voter.update(disabled: true)
    redirect_to root_path, notice: "Row disabled successfully."
  end

  def kid_lock
    kid = params[:kid].to_s.strip
    
    if kid.blank?
      redirect_to root_path, alert: "KID number is required."
      return
    end
    
    # Find voter by KID - try exact match first, then partial match
    voter = Voter.where(kid: kid).first || Voter.where("kid LIKE ?", "%#{kid}%").first
    
    if voter.nil?
      redirect_to root_path, alert: "Voter with KID '#{kid}' not found."
      return
    end
    
    # Check if voter has execution_no - only lock if execution_no exists
    if voter.execution_no.blank?
      redirect_to root_path, alert: "Voter with KID '#{kid}' does not have an execution number. Cannot lock."
      return
    end
    
    if voter.disabled == true
      redirect_to root_path, alert: "Voter with KID '#{kid}' is already locked."
      return
    end
    
    # Lock the voter: set printed=true (counts in attendance) and disabled=true (locks)
    # Do NOT increment token_number and do NOT print
    voter.update(printed: true, disabled: true)
    
    redirect_to root_path, notice: "Voter with KID '#{kid}' has been locked and counted in attendance."
  end

  private

  def set_voter
    @voter = Voter.find(params[:id])
  end

  def voter_params
    params.require(:voter).permit(:cnic, :kid, :name, :father_name, :age, :date_of_birth, :voter_status, :guest_entry)
  end
end
