class AddDisabledToVoters < ActiveRecord::Migration[7.0]
  def change
    add_column :voters, :disabled, :boolean
  end
end
