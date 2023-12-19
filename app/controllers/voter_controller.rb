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
    @voter = Voter.new(voter_params)

    if @voter.save
      redirect_to @voter, notice: 'Voter was successfully created.'
    else
      render :new
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
    @voters = Voter.search(params[:query])
    render :index
  end

  def print
    puts "Print"
    @voter = Voter.find(params[:id])
    lock
    respond_to do |format|
      format.html { render layout: 'layouts/printable' } # Renders the HTML version using the printable layout
    end
  end

  def lock
    puts "Lock"
    @voter = Voter.find(params[:id])
    @voter.update(disabled: true)
    redirect_to voter_index_path, notice: "Row disabled successfully." if !params[:action].eql?("print")
  end

  private

  def set_voter
    @voter = Voter.find(params[:id])
  end

  def voter_params
    params.require(:voter).permit(:cnic, :kid, :name, :father_name, :age, :date_of_birth, :voter_status)
  end
end
