class Voter < ApplicationRecord
  include PgSearch::Model
  
  # Optimized search using both full-text and trigram search
  pg_search_scope :search, 
    against: [:cnic, :kid, :name, :father_name, :voter_no, :cnic_chk, :family_no, :kid_chk],
    using: {
      tsearch: { prefix: true, any_word: true },
      trigram: { threshold: 0.3 }
    },
    ignoring: :accents

  # Fast exact match search for CNIC/KID lookups
  scope :by_cnic, ->(cnic) { where("cnic LIKE ?", "%#{cnic}%") }
  scope :by_kid, ->(kid) { where("kid LIKE ?", "%#{kid}%") }
  
  # Scopes for gender filtering
  scope :male, -> { where("CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 != 0") }
  scope :female, -> { where("CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 = 0") }
  scope :printed, -> { where(printed: true) }
  scope :pending, -> { where(printed: false) }
  scope :guests, -> { where(guest_entry: true) }

  # Instance method for gender
  def gender
    cnic.to_i.even? ? "Female" : "Male"
  end

  def male?
    cnic.to_i.odd?
  end

  def female?
    cnic.to_i.even?
  end

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