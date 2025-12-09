class AddIndexesToVoters < ActiveRecord::Migration[7.0]
  def change
    # Add pg_trgm extension for trigram (fuzzy) search
    enable_extension 'pg_trgm'

    # B-tree indexes for exact lookups (most frequently searched fields)
    add_index :voters, :cnic
    add_index :voters, :kid
    add_index :voters, :kid_chk
    add_index :voters, :family_no
    add_index :voters, :voter_no
    add_index :voters, :cnic_chk

    # Indexes for filtering
    add_index :voters, :printed
    add_index :voters, :disabled
    add_index :voters, :guest_entry

    # GIN indexes for fast text search using trigrams
    add_index :voters, :name, using: :gin, opclass: :gin_trgm_ops
    add_index :voters, :father_name, using: :gin, opclass: :gin_trgm_ops

    # Composite index for common queries
    add_index :voters, [:printed, :updated_at]
  end
end
