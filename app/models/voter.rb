class Voter < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search, against: [:cnic, :kid, :name, :father_name],
    using: { tsearch: { any_word: true, prefix: true } }
  
  def male
    Voter.where(cnic: "CAST(cnic AS INTEGER) % 2 = 0")
  end

  # scope :male, -> { where("LENGTH(cnic) > 0 AND CAST(SUBSTRING(cnic, -1) AS INTEGER) % 2 != 0") }

  def unlock
    self.update(printed: false)
    self.update(disabled: false)
  end
end
