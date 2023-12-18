class CreateVoters < ActiveRecord::Migration[7.0]
  def change
    create_table :voters do |t|
      t.string :cnic
      t.string :kid
      t.string :name
      t.string :father_name
      t.integer :age
      t.date :date_of_birth
      t.string :voter_status

      t.timestamps
    end
  end
end
