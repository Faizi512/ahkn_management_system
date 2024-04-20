class AddColumnToVoter < ActiveRecord::Migration[7.0]
  def change
    add_column :voters, :guest_entry, :boolean
  end
end
