class AddPrintedToVoters < ActiveRecord::Migration[7.0]
  def change
    add_column :voters, :printed, :boolean
  end
end
