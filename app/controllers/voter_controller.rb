require 'tzinfo'
class VoterController < ApplicationController
  before_action :set_voter, only: [:show, :edit, :update, :destroy]
  

  def index
    @voters = (!params[:gender_filter].nil? && !params[:gender_filter].eql?("All")) ? params[:gender_filter].eql?("Male") ? Voter.where("CAST(cnic AS BIGINT) % 2 != 0") : Voter.where("CAST(cnic AS BIGINT) % 2 = 0") : Voter.all
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
      if !Voter.where(cnic: params[:cnic]).present?
        @voter = Voter.new(name: params[:name], qabeela: params[:qabeela], urfiat: params[:urfiat], cell_no: params[:phone], cnic: params[:cnic], guest_entry: params[:guest_entry])
        @voter.update!(token_number: @voter.next_token_number)
      else
        redirect_to "/voter/search?query=#{params[:cnic]}&commit=Search"
      end
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
    query = params[:query].to_s
    truncated_query = query.length > 13 ? query[12, 13] : query
    @voters = Voter.search(truncated_query)
    render :show
  end

  def print
    puts "Print"
    tz = TZInfo::Timezone.get('Asia/Karachi')
    @local_time = tz.to_local(Time.now.utc)
    @voter = Voter.find(params[:id])
    @voter.update(token_number: @voter.next_token_number) if @voter.printed == false
    @voter.update(printed: true)
    lock
    respond_to do |format|
      format.html { render layout: 'layouts/printable' } # Renders the HTML version using the printable layout
    end
  end

  def special_print
    puts "Special Print"
    @voter = Voter.find(params[:id])
    # @voter.update(token_number: @voter.next_token_number) if @voter.printed == false
    @voter.update(printed: true)
    lock
    respond_to do |format|
      format.html { render layout: 'layouts/printable' } # Renders the HTML version using the printable layout
    end
  end

  def lock
    puts "Lock"
    @voter = Voter.find(params[:id])
    @voter.update(disabled: true)
    redirect_to root_path, notice: "Row disabled successfully." if !params[:action].eql?("print") && !params[:action].eql?("special_print")
  end

  private

  def set_voter
    @voter = Voter.find(params[:id])
  end

  def voter_params
    params.require(:voter).permit(:cnic, :kid, :name, :father_name, :age, :date_of_birth, :voter_status, :guest_entry)
  end
end
