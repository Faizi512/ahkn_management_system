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
  scope :male, -> { where("cnic IS NOT NULL AND cnic != '' AND CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 != 0") }
  scope :female, -> { where("cnic IS NOT NULL AND cnic != '' AND CAST(REGEXP_REPLACE(cnic, '[^0-9]', '', 'g') AS BIGINT) % 2 = 0") }
  scope :printed, -> { where(printed: true) }
  scope :pending, -> { where(printed: false) }
  scope :guests, -> { where(guest_entry: true) }

  # Validations for guest entries
  validates :name, presence: { message: "Name is required" }, if: :guest_entry?
  validates :qabeela, presence: { message: "Qabeela is required" }, if: :guest_entry?
  validates :urfiat, presence: { message: "Urfiat is required" }, if: :guest_entry?
  validates :cell_no, presence: { message: "Phone is required" }, if: :guest_entry?
  validates :execution_no, presence: { message: "Execution No is required" }, if: :guest_entry?
  validates :cnic, presence: { message: "CNIC is required" }, if: :guest_entry?

  def guest_entry?
    guest_entry == true
  end

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

  # Format DOB as dd-mm-yyyy
  def formatted_dob
    return dob if dob.blank?
    begin
      Date.parse(dob.to_s).strftime("%d-%m-%Y")
    rescue
      dob  # Return original if parsing fails
    end
  end

  def unlock
    self.update(printed: false)
    self.update(disabled: false)
  end

  def self.reset_token
    self.update!(token_number: 0)
  end

  def next_token_number
    # Use raw SQL for faster MAX query with index hint
    result = Voter.connection.select_value("SELECT COALESCE(MAX(token_number), 0) + 1 FROM voters")
    result.to_i
  end
end