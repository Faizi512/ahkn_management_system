class Voter < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search, against: [:cnic, :kid, :name, :father_name, :voter_no, :cnic_chk, :family_no, :kid_chk],
    using: { tsearch: { any_word: true, prefix: true } }
  
  def male
    Voter.where(cnic: "CAST(cnic AS INTEGER) % 2 = 0")
  end

  # scope :male, -> { where("LENGTH(cnic) > 0 AND CAST(SUBSTRING(cnic, -1) AS INTEGER) % 2 != 0") }

  def unlock
    self.update(printed: false)
    self.update(disabled: false)
  end

  def self.reset_token
    self.update!(token_number: 0)
  end

  def next_token_number
    last_token_number = Voter.maximum(:token_number) || 0
    last_token_number + 1
  end
end