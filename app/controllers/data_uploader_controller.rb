class DataUploaderController < ApplicationController

  def new
    @voter = Voter.new
  end

  def create
    if params[:file].present?
      begin
        DataLoaderService.new(params[:file]).load_voters
        redirect_to voters_path, notice: 'Voters data imported successfully.'
      rescue StandardError => e
        redirect_to new_data_uploader_path, alert: "Error importing voters data: #{e.message}"
      end
    else
      redirect_to new_data_uploader_path, alert: 'Please select a file.'
    end
  end
end
