class AddTokenNumberToVoters < ActiveRecord::Migration[7.0]
  def change
    add_column :voters, :token_number, :integer
  end
end
