class AddIndexToTokenNumber < ActiveRecord::Migration[7.0]
  def change
    add_index :voters, :token_number
  end
end
