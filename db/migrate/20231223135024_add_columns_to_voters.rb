class AddColumnsToVoters < ActiveRecord::Migration[7.0]
  def change
    add_column :voters, :voter_no, :string
    add_column :voters, :akhn, :string
    add_column :voters, :verification, :string
    add_column :voters, :execution_no, :string
    add_column :voters, :f_cnic, :string
    add_column :voters, :spouse_name, :string
    add_column :voters, :sp_cnic, :string
    add_column :voters, :qaber, :string
    add_column :voters, :address, :string
    add_column :voters, :city, :string
    add_column :voters, :cell_no, :string
    add_column :voters, :mobile, :string
    add_column :voters, :cnic_chk, :string
    add_column :voters, :qabeela, :string
    add_column :voters, :urfiat, :string
    add_column :voters, :wf_upto, :string
    add_column :voters, :family_no, :string
    add_column :voters, :dob, :string
    add_column :voters, :kid_chk, :string
  end
end
