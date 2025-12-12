class AddUserCodeToVoters < ActiveRecord::Migration[7.0]
  def change
    add_column :voters, :user_code, :string
  end
end
